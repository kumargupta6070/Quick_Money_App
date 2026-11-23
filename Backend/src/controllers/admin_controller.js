const { User, Order, Transaction, Wallet, DailyProfit, Notification, SystemSetting, AuditLog, SupportTicket, sequelize } = require('../models');
const ResponseHandler = require('../utils/response_handler');
const { decrypt } = require('../utils/crypto_helper');
const { Op } = require('sequelize');

class AdminController {
  /**
   * 1. Platform-wide aggregated stats for Admin Dashboard
   */
  static async getPlatformStats(req, res) {
    try {
      const totalUsers = await User.count({ where: { role: 'user' } });
      const activeUsers = await User.count({ where: { role: 'user', status: 'active' } });
      const bannedUsers = await User.count({ where: { role: 'user', status: 'banned' } });

      const totalOrders = await Order.count();
      const activePackages = await Order.count({ where: { status: 'active' } });
      const completedOrders = await Order.count({ where: { status: 'completed' } });

      const totalVolumeResult = await Order.sum('order_amount');
      const totalPlatformVolume = parseFloat(totalVolumeResult || '0');

      const totalUserBalanceResult = await User.sum('balance', { where: { role: 'user' } });
      const totalUserBalanceFloat = parseFloat(totalUserBalanceResult || '0');

      const pendingPayoutsCount = await Transaction.count({
        where: {
          type: 'payout',
          status: 'pending',
        },
      });

      const totalPendingPayoutsSum = await Transaction.sum('amount', {
        where: {
          type: 'payout',
          status: 'pending',
        },
      });

      const totalPayoutsSettledResult = await Transaction.sum('amount', {
        where: {
          type: 'payout',
          status: 'completed',
        },
      });
      const totalPayoutsSettled = parseFloat(totalPayoutsSettledResult || '0');

      return ResponseHandler.success(res, {
        overview: {
          totalUsers,
          activeUsers,
          bannedUsers,
          totalOrders,
          activePackages,
          completedOrders,
          totalPlatformVolume,
          totalUserBalanceFloat,
          pendingPayoutsCount,
          totalPendingPayoutsAmount: parseFloat(totalPendingPayoutsSum || '0'),
          totalPayoutsSettled,
        },
        marketStatus: 'ONLINE',
        vaultSecurity: 'AES-256-CBC Active',
        serverTime: new Date().toISOString(),
      }, 'Admin platform stats retrieved successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 2. List pending withdrawal requests for PhonePe payout settlement
   */
  static async getPendingPayouts(req, res) {
    try {
      const payouts = await Transaction.findAll({
        where: {
          type: 'payout',
          status: 'pending',
        },
        include: [{
          model: User,
          as: 'user',
          attributes: ['id', 'email', 'mobile_encrypted', 'invite_code', 'balance'],
        }],
        order: [['created_at', 'ASC']],
        limit: 100,
      });

      const formatted = payouts.map((p) => {
        let destinationUpi = 'UPI Hidden';
        try {
          destinationUpi = decrypt(p.payment_destination_encrypted);
        } catch {
          destinationUpi = 'UPI Decrypt Error';
        }

        let userMobile = 'N/A';
        if (p.user && p.user.mobile_encrypted) {
          try {
            userMobile = decrypt(p.user.mobile_encrypted);
          } catch {
            userMobile = 'N/A';
          }
        }

        return {
          id: p.id,
          userId: p.user_id,
          userEmail: p.user?.email || 'N/A',
          userMobile,
          userInviteCode: p.user?.invite_code || 'N/A',
          amount: parseFloat(p.amount),
          profitAccumulated: parseFloat(p.profit || 0),
          paymentMethod: p.payment_method,
          destinationUpi,
          status: p.status,
          requestedAt: p.created_at,
        };
      });

      return ResponseHandler.success(res, formatted, 'Pending payouts fetched successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 3. Settle / Complete a pending payout transaction with Bank UTR reference
   */
  static async settlePayout(req, res) {
    try {
      const { id } = req.params;
      const { utrReference } = req.body;

      const transaction = await Transaction.findByPk(id);
      if (!transaction) {
        return ResponseHandler.error(res, 'Payout transaction not found', 404);
      }
      if (transaction.type !== 'payout') {
        return ResponseHandler.error(res, 'Transaction is not a payout request', 400);
      }
      if (transaction.status === 'completed') {
        return ResponseHandler.error(res, 'Payout is already settled', 400);
      }

      const { encrypt } = require('../config/encryption');
      const finalRef = utrReference && utrReference.trim().length > 0 ? utrReference.trim() : `UTR-${Date.now()}`;

      // Atomic Status Lock (Prevents concurrent settlement)
      const [affectedRows] = await Transaction.update(
        {
          status: 'completed',
          payment_reference_encrypted: encrypt(finalRef),
        },
        {
          where: { id: transaction.id, status: 'pending' },
        }
      );

      if (affectedRows === 0) {
        return ResponseHandler.error(res, 'Payout is already settled or rejected', 400);
      }

      // Send in-app notification to user
      await Notification.create({
        user_id: transaction.user_id,
        title: 'PhonePe Return Settled! 🎉',
        message: `Your payout of ₹${parseFloat(transaction.amount).toFixed(2)} has been successfully transferred to your PhonePe UPI. Bank UTR: ${finalRef}`,
        type: 'transaction',
        is_read: false,
      });

      return ResponseHandler.success(res, {
        id: transaction.id,
        status: 'completed',
        utrReference: finalRef,
      }, 'Payout marked as successfully settled to user PhonePe account');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 3b. Reject a pending payout transaction and refund user wallet
   */
  static async rejectPayout(req, res) {
    try {
      const { id } = req.params;
      const transaction = await Transaction.findByPk(id);
      if (!transaction) {
        return ResponseHandler.error(res, 'Payout transaction not found', 404);
      }
      if (transaction.type !== 'payout') {
        return ResponseHandler.error(res, 'Transaction is not a payout request', 400);
      }
      if (transaction.status === 'completed') {
        return ResponseHandler.error(res, 'Payout is already settled', 400);
      }
      if (transaction.status === 'failed') {
        return ResponseHandler.error(res, 'Payout is already rejected', 400);
      }

      // Atomic status lock (Prevents concurrent duplicate refund)
      const [affectedRows] = await Transaction.update(
        { status: 'failed' },
        { where: { id: transaction.id, status: 'pending' } }
      );

      if (affectedRows === 0) {
        return ResponseHandler.error(res, 'Payout is already processed', 400);
      }

      // Refund the amount back to user's balance
      const user = await User.findByPk(transaction.user_id);
      if (user) {
        user.balance = (parseFloat(user.balance) + parseFloat(transaction.amount)).toFixed(2);
        await user.save();
      }

      // Notify user
      await Notification.create({
        user_id: transaction.user_id,
        title: 'Payout Request Rejected',
        message: `Your payout request of ₹${parseFloat(transaction.amount).toFixed(2)} could not be processed. The amount has been refunded to your wallet.`,
        type: 'transaction',
        is_read: false,
      });

      return ResponseHandler.success(res, { id: transaction.id, status: 'failed' }, 'Payout rejected and refunded to user wallet');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 4. List all packages for SuperAdmin with Level filters
   */
  static async listAllPackages(req, res) {
    try {
        const { level, status } = req.query;
        const whereClause = {};
        if(level && level !== 'ALL') {
          whereClause.level = level;
    }
      if (status && status !== 'ALL') {
      whereClause.status = status;
    }

    const packages = await Order.findAll({
      where: whereClause,
      order: [['level', 'ASC'], ['order_amount', 'ASC']],
    });

    return ResponseHandler.success(res, packages, 'RP Packages retrieved successfully');
  } catch(err) {
    return ResponseHandler.error(res, err.message, 500);
  }
}

  /**
   * 5. Create a new RP market package
   */
  static async createPackage(req, res) {
    try {
      const { order_amount, order_quantity, reward, bonus, level, status } = req.body;
      const amount = parseFloat(order_amount || 0);
      const qty = parseInt(order_quantity || 1, 10);
      const rew = parseFloat(reward || 0);
      const bon = parseFloat(bonus || 0);
      const lvl = level || 'L1';
      const stat = status || 'active';
      const finalRp = amount + rew + bon;

      if (amount <= 0) {
        return ResponseHandler.error(res, 'Order amount must be greater than 0', 400);
      }

      const pkg = await Order.create({
        seller_id: req.user.id,
        order_amount: amount,
        order_quantity: qty,
        reward: rew,
        bonus: bon,
        final_rp: finalRp,
        level: lvl,
        status: stat,
      });

      return ResponseHandler.success(res, pkg, 'RP package created successfully', 201);
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 6. Update an existing RP package
   */
  static async updatePackage(req, res) {
    try {
      const { id } = req.params;
      const pkg = await Order.findByPk(id);
      if (!pkg) {
        return ResponseHandler.error(res, 'Package not found', 404);
      }

      const { order_amount, order_quantity, reward, bonus, level, status } = req.body;
      if (order_amount !== undefined) pkg.order_amount = parseFloat(order_amount);
      if (order_quantity !== undefined) pkg.order_quantity = parseInt(order_quantity, 10);
      if (reward !== undefined) pkg.reward = parseFloat(reward);
      if (bonus !== undefined) pkg.bonus = parseFloat(bonus);
      if (level !== undefined) pkg.level = level;
      if (status !== undefined) pkg.status = status;
      pkg.final_rp = parseFloat(pkg.order_amount) + parseFloat(pkg.reward) + parseFloat(pkg.bonus);

      await pkg.save();

      return ResponseHandler.success(res, pkg, 'RP package updated successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 7. Delete an RP package
   */
  static async deletePackage(req, res) {
    try {
      const { id } = req.params;
      const pkg = await Order.findByPk(id);
      if (!pkg) {
        return ResponseHandler.error(res, 'Package not found', 404);
      }

      await pkg.destroy();
      return ResponseHandler.success(res, { id }, 'RP package deleted successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 8. Search & List Users with Pagination & Filters
   */
  static async listUsers(req, res) {
    try {
      const { query, status, limit = 50, offset = 0 } = req.query;
      const whereClause = { role: 'user' };

      if (status && status !== 'ALL') {
        whereClause.status = status;
      }

      if (query && query.trim().length > 0) {
        const q = query.trim().toLowerCase();
        whereClause[Op.or] = [
          { email: { [Op.like]: `%${q}%` } },
          { invite_code: { [Op.like]: `%${q}%` } },
          { referred_by: { [Op.like]: `%${q}%` } },
        ];
      }

      const { count, rows } = await User.findAndCountAll({
        where: whereClause,
        attributes: ['id', 'email', 'mobile_encrypted', 'invite_code', 'referred_by', 'role', 'balance', 'level', 'status', 'created_at'],
        order: [['created_at', 'DESC']],
        limit: parseInt(limit, 10),
        offset: parseInt(offset, 10),
      });

      const formatted = rows.map((u) => {
        let mobile = 'N/A';
        try {
          mobile = decrypt(u.mobile_encrypted);
          if (mobile === 'TEST_ENC_MOBILE') mobile = '+91 98765 43210';
        } catch {
          mobile = 'N/A';
        }

        return {
          id: u.id,
          email: u.email,
          mobile,
          invite_code: u.invite_code,
          referred_by: u.referred_by || 'DIRECT',
          balance: parseFloat(u.balance),
          level: u.level,
          status: u.status,
          created_at: u.created_at,
        };
      });

      return ResponseHandler.success(res, {
        total: count,
        users: formatted,
      }, 'Users retrieved successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 9. Update User Status (Freeze/Ban vs Activate)
   */
  static async updateUserStatus(req, res) {
    try {
      const { id } = req.params;
      const { status } = req.body;

      if (!['active', 'banned', 'suspended'].includes(status)) {
        return ResponseHandler.error(res, 'Invalid status value', 400);
      }

      const user = await User.findByPk(id);
      if (!user) {
        return ResponseHandler.error(res, 'User not found', 404);
      }

      user.status = status;
      await user.save();

      return ResponseHandler.success(res, {
        id: user.id,
        status: user.status,
      }, `User account status updated to ${status}`);
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 10. Manually Adjust User Balance (Bonus, Correction, Debit)
   */
  static async adjustUserBalance(req, res) {
    try {
      const { id } = req.params;
      const { amount, type = 'credit', reason = 'Admin Balance Adjustment' } = req.body;
      const adjustVal = parseFloat(amount || 0);

      if (adjustVal <= 0) {
        return ResponseHandler.error(res, 'Adjustment amount must be greater than 0', 400);
      }

      const user = await User.findByPk(id);
      if (!user) {
        return ResponseHandler.error(res, 'User not found', 404);
      }

      if (type === 'debit') {
        if (parseFloat(user.balance) < adjustVal) {
          return ResponseHandler.error(res, 'User balance is insufficient for debit', 400);
        }
        await user.decrement('balance', { by: adjustVal });
      } else {
        await user.increment('balance', { by: adjustVal });
      }

      await user.reload();

      // Record audit transaction
      const { encrypt } = require('../config/encryption');
      await Transaction.create({
        user_id: user.id,
        type: type === 'debit' ? 'sell' : 'reward',
        amount: adjustVal,
        profit: 0,
        payment_method: 'admin_manual',
        payment_reference_encrypted: encrypt(reason),
        status: 'completed',
      });

      // Send Notification to user
      await Notification.create({
        user_id: user.id,
        title: type === 'debit' ? 'Account Balance Debited' : 'Account Balance Credited! 🎁',
        message: `An amount of ₹${adjustVal.toFixed(2)} was ${type === 'debit' ? 'deducted from' : 'credited to'} your account. Reason: ${reason}`,
        type: 'transaction',
        is_read: false,
      });

      return ResponseHandler.success(res, {
        id: user.id,
        newBalance: parseFloat(user.balance),
        adjustmentType: type,
        amount: adjustVal,
      }, `Successfully ${type}ed ₹${adjustVal.toFixed(2)} to user account`);
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 11. Get Platform Configuration Settings
   */
  static async getPlatformSettings(req, res) {
    try {
      const defaults = {
        daily_yield_rate: '0.025',
        level1_rebate_percent: '0.05',
        level2_rebate_percent: '0.03',
        level3_rebate_percent: '0.01',
        profit_return_threshold: '100.00',
        welcome_bonus: '51.07',
        market_status: 'ONLINE',
        announcement_text: '⚡ Quick Money High-Yield Trading Live — PhonePe ₹100 Auto-Return Active!',
      };

      const settings = await SystemSetting.findAll();
      const settingsMap = { ...defaults };
      for (const s of settings) {
        settingsMap[s.key] = s.value;
      }

      return ResponseHandler.success(res, settingsMap, 'Platform settings retrieved successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 12. Update Platform Configuration Settings
   */
  static async updatePlatformSettings(req, res) {
    try {
      const { settings } = req.body;
      if (!settings || typeof settings !== 'object') {
        return ResponseHandler.error(res, 'Settings object is required', 400);
      }

      for (const [key, value] of Object.entries(settings)) {
        await SystemSetting.upsert({
          key,
          value: String(value),
        });
      }

      const all = await SystemSetting.findAll();
      const updatedMap = {};
      for (const s of all) {
        updatedMap[s.key] = s.value;
      }

      return ResponseHandler.success(res, updatedMap, 'Platform settings updated successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 13. Broadcast Global Announcement to all active users
   */
  static async broadcastNotification(req, res) {
    try {
      const { title, message, type = 'system' } = req.body;
      if (!title || !message) {
        return ResponseHandler.error(res, 'Title and Message are required for broadcast', 400);
      }

      const users = await User.findAll({ where: { role: 'user', status: 'active' }, attributes: ['id'] });
      const notifications = users.map((u) => ({
        user_id: u.id,
        title,
        message,
        type,
        is_read: false,
      }));

      await Notification.bulkCreate(notifications);

      return ResponseHandler.success(res, {
        recipientsCount: users.length,
        title,
        message,
      }, `Announcement broadcasted to ${users.length} active traders!`);
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 7. Trigger Daily Yield & ₹100 Auto-Disbursement Cycle on demand
   */
  static async triggerYieldCycle(req, res) {
    try {
      const YieldScheduler = require('../services/yield_scheduler');
      const result = await YieldScheduler.runDailyCycle();
      return ResponseHandler.success(res, result, 'Daily yield cycle executed successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 8. User Full Kundali / 360-Degree Dossier
   */
  static async getUserKundali(req, res) {
    try {
      const { id } = req.params;
      const user = await User.findByPk(id);
      if (!user) return ResponseHandler.error(res, 'User not found', 404);

      let mobile = 'N/A';
      try {
        mobile = decrypt(user.mobile_encrypted);
        if (mobile === 'TEST_ENC_MOBILE') mobile = '+91 98765 43210';
      } catch {
        mobile = 'N/A';
      }

      const wallet = await Wallet.findOne({ where: { user_id: user.id } });

      const orders = await Order.findAll({
        where: { buyer_id: user.id },
        order: [['created_at', 'DESC']],
      });
      const totalInvested = orders.reduce((sum, o) => sum + parseFloat(o.order_amount || '0'), 0);

      const transactions = await Transaction.findAll({
        where: { user_id: user.id },
        order: [['created_at', 'DESC']],
        limit: 50,
      });

      const totalDeposited = transactions
        .filter(t => t.type === 'deposit' && t.status === 'completed')
        .reduce((sum, t) => sum + parseFloat(t.amount || '0'), 0);

      const totalPayouts = transactions
        .filter(t => t.type === 'payout' && t.status === 'completed')
        .reduce((sum, t) => sum + parseFloat(t.amount || '0'), 0);

      const totalYieldEarned = await DailyProfit.sum('total_income', { where: { user_id: user.id } }) || 0;

      const totalRebatesEarned = transactions
        .filter(t => t.type === 'rebate' && t.status === 'completed')
        .reduce((sum, t) => sum + parseFloat(t.amount || '0'), 0);

      let referrerInfo = null;
      if (user.referred_by) {
        const parent = await User.findOne({ where: { invite_code: user.referred_by } });
        if (parent) {
          referrerInfo = {
            id: parent.id,
            email: parent.email,
            invite_code: parent.invite_code,
          };
        }
      }

      const l1Users = await User.findAll({
        where: { referred_by: user.invite_code },
        attributes: ['id', 'email', 'level', 'status', 'created_at'],
      });
      const l1Codes = l1Users.map(u => u.invite_code).filter(Boolean);

      const l2Users = l1Codes.length > 0
        ? await User.findAll({ where: { referred_by: { [Op.in]: l1Codes } }, attributes: ['id', 'email', 'level', 'status'] })
        : [];
      const l2Codes = l2Users.map(u => u.invite_code).filter(Boolean);

      const l3Users = l2Codes.length > 0
        ? await User.findAll({ where: { referred_by: { [Op.in]: l2Codes } }, attributes: ['id', 'email', 'level', 'status'] })
        : [];

      return ResponseHandler.success(res, {
        profile: {
          id: user.id,
          email: user.email,
          mobile,
          role: user.role,
          level: user.level,
          balance: parseFloat(user.balance || '0'),
          status: user.status,
          invite_code: user.invite_code,
          referred_by: user.referred_by,
          created_at: user.created_at,
        },
        financials: {
          balance: parseFloat(user.balance || '0'),
          totalInvested,
          totalDeposited,
          totalPayouts,
          totalYieldEarned: parseFloat(totalYieldEarned || '0'),
          totalRebatesEarned,
          netPnl: (totalPayouts + parseFloat(user.balance || '0')) - totalDeposited,
        },
        wallet: wallet ? {
          app_name: wallet.payment_app || 'phonepe',
          account_identifier: wallet.upi_id_encrypted ? (function() { try { return decrypt(wallet.upi_id_encrypted); } catch { return 'Encrypted'; } })() : 'N/A',
          account_holder_name: wallet.account_name_encrypted ? (function() { try { return decrypt(wallet.account_name_encrypted); } catch { return 'Verified Trader'; } })() : 'Verified Trader',
          status: wallet.status,
          bound_at: wallet.created_at,
        } : null,
        referrals: {
          referrer: referrerInfo,
          l1Count: l1Users.length,
          l2Count: l2Users.length,
          l3Count: l3Users.length,
          totalTeamSize: l1Users.length + l2Users.length + l3Users.length,
          l1Members: l1Users.slice(0, 10),
        },
        orders: orders.map(o => ({
          id: o.id,
          package_name: o.package_name || `Tier ${o.level} RP Order`,
          amount: parseFloat(o.order_amount || '0'),
          yield_rate: parseFloat(o.daily_yield_rate || '0.025') * 100,
          status: o.status,
          created_at: o.created_at,
        })),
        transactions: transactions.map(t => ({
          id: t.id,
          type: t.type,
          amount: parseFloat(t.amount || '0'),
          status: t.status,
          reference: t.reference_id,
          description: t.description,
          created_at: t.created_at,
        })),
      }, 'User Kundali fetched successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 9. Permanent User Deletion with Cascade Integrity
   */
  static async deleteUserPermanently(req, res) {
    const transaction = await sequelize.transaction();
    try {
      const { id } = req.params;
      const user = await User.findByPk(id, { transaction });
      if (!user) {
        await transaction.rollback();
        return ResponseHandler.error(res, 'User not found', 404);
      }

      if (user.role === 'admin') {
        await transaction.rollback();
        return ResponseHandler.error(res, 'Super Admin accounts cannot be deleted.', 403);
      }

      const { Otp } = require('../models');

      await Notification.destroy({ where: { user_id: user.id }, transaction });
      await DailyProfit.destroy({ where: { user_id: user.id }, transaction });
      await Transaction.destroy({ where: { user_id: user.id }, transaction });
      await Order.destroy({ where: { [Op.or]: [{ buyer_id: user.id }, { seller_id: user.id }] }, transaction });
      await Wallet.destroy({ where: { user_id: user.id }, transaction });
      await Otp.destroy({ where: { email: user.email }, transaction });
      await User.update({ referred_by: null }, { where: { referred_by: user.invite_code }, transaction });
      await user.destroy({ transaction });

      await AuditLog.create({
        admin_id: req.user ? req.user.id : null,
        action: 'DELETE_USER',
        target_type: 'user',
        target_id: String(user.id),
        details: `Permanently deleted user: ${user.email} (Invite: ${user.invite_code})`,
        ip_address: req.ip,
      }, { transaction });

      await transaction.commit();
      return ResponseHandler.success(res, { deletedUserId: id, email: user.email }, 'User deleted permanently along with all dependent records.');
    } catch (err) {
      await transaction.rollback();
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 10. Manual UTR Verification & Approval Console
   */
  static async getPendingUtrs(req, res) {
    try {
      const orders = await Order.findAll({
        where: {
          [Op.or]: [
            { utr_number: { [Op.ne]: null } },
            { status: 'pending' },
          ],
        },
        include: [{ model: User, as: 'buyer', attributes: ['id', 'email', 'mobile_encrypted'] }],
        order: [['created_at', 'DESC']],
        limit: 50,
      });

      const formatted = orders.map(o => {
        let mobile = 'N/A';
        if (o.buyer && o.buyer.mobile_encrypted) {
          try { mobile = decrypt(o.buyer.mobile_encrypted); } catch { mobile = 'N/A'; }
        }
        return {
          id: o.id,
          order_amount: parseFloat(o.order_amount || '0'),
          level: o.level,
          package_name: o.package_name || `Tier ${o.level} RP Order`,
          utr_number: o.utr_number,
          status: o.status,
          user: o.buyer ? { id: o.buyer.id, email: o.buyer.email, mobile } : null,
          created_at: o.created_at,
        };
      });

      return ResponseHandler.success(res, formatted, 'Pending UTR orders fetched successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async approveUtr(req, res) {
    const t = await sequelize.transaction();
    try {
      const { id } = req.params;
      const order = await Order.findByPk(id, { transaction: t });
      if (!order) {
        await t.rollback();
        return ResponseHandler.error(res, 'Order not found', 404);
      }
      if (order.status === 'active' || order.status === 'completed') {
        await t.rollback();
        return ResponseHandler.error(res, 'Order is already approved/active', 400);
      }

      order.status = 'active';
      await order.save({ transaction: t });

      await Transaction.create({
        user_id: order.buyer_id,
        type: 'deposit',
        amount: order.order_amount,
        status: 'completed',
        reference_id: order.utr_number || `UTR-APP-${Date.now()}`,
        description: `Manual UTR Deposit Approved for ${order.package_name || 'RP Package'}`,
      }, { transaction: t });

      await Notification.create({
        user_id: order.buyer_id,
        title: 'UTR Deposit Approved! 💰',
        message: `Your deposit of ₹${order.order_amount} has been verified & approved. Your RP package is now generating daily returns!`,
        type: 'order',
        is_read: false,
      }, { transaction: t });

      const ReferralService = require('../services/referral_service');
      await ReferralService.distributeRebate(order.buyer_id, parseFloat(order.order_amount));

      await AuditLog.create({
        admin_id: req.user ? req.user.id : null,
        action: 'APPROVE_UTR',
        target_type: 'order',
        target_id: String(order.id),
        details: `Approved UTR ${order.utr_number} for Order #${order.id} (₹${order.order_amount})`,
        ip_address: req.ip,
      }, { transaction: t });

      await t.commit();
      return ResponseHandler.success(res, { orderId: order.id, status: 'active' }, 'UTR verified and package activated successfully!');
    } catch (err) {
      await t.rollback();
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async rejectUtr(req, res) {
    try {
      const { id } = req.params;
      const { reason } = req.body;
      const order = await Order.findByPk(id);
      if (!order) return ResponseHandler.error(res, 'Order not found', 404);

      order.status = 'rejected';
      await order.save();

      await Notification.create({
        user_id: order.buyer_id,
        title: 'UTR Verification Rejected ⚠️',
        message: `Your UTR deposit of ₹${order.order_amount} could not be verified. Reason: ${reason || 'Invalid UTR reference number'}. Please contact support.`,
        type: 'system',
        is_read: false,
      });

      await AuditLog.create({
        admin_id: req.user ? req.user.id : null,
        action: 'REJECT_UTR',
        target_type: 'order',
        target_id: String(order.id),
        details: `Rejected UTR ${order.utr_number} for Order #${order.id}. Reason: ${reason || 'Invalid UTR'}`,
        ip_address: req.ip,
      });

      return ResponseHandler.success(res, { orderId: order.id, status: 'rejected' }, 'UTR rejected.');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 11. Customer Support Ticket Desk
   */
  static async listSupportTickets(req, res) {
    try {
      const tickets = await SupportTicket.findAll({
        order: [['created_at', 'DESC']],
        limit: 50,
      });
      return ResponseHandler.success(res, tickets, 'Support tickets fetched successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async replySupportTicket(req, res) {
    try {
      const { id } = req.params;
      const { reply, status = 'resolved' } = req.body;
      const ticket = await SupportTicket.findByPk(id);
      if (!ticket) return ResponseHandler.error(res, 'Ticket not found', 404);

      ticket.admin_reply = reply;
      ticket.status = status;
      if (status === 'resolved') ticket.resolved_at = new Date();
      await ticket.save();

      await Notification.create({
        user_id: ticket.user_id,
        title: `Support Ticket Update #${ticket.ticket_number} 📨`,
        message: `Admin Response: "${reply}". Status: ${status.toUpperCase()}.`,
        type: 'system',
        is_read: false,
      });

      return ResponseHandler.success(res, ticket, 'Ticket reply submitted and user notified');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 12. System Audit Logs & Live Solvency Health
   */
  static async listAuditLogs(req, res) {
    try {
      const logs = await AuditLog.findAll({
        order: [['created_at', 'DESC']],
        limit: 50,
      });
      return ResponseHandler.success(res, logs, 'Audit logs fetched');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async getSolvencyMetrics(req, res) {
    try {
      const totalDeposited = await Transaction.sum('amount', { where: { type: 'deposit', status: 'completed' } }) || 0;
      const totalPayouts = await Transaction.sum('amount', { where: { type: 'payout', status: 'completed' } }) || 0;
      const totalUserBalance = await User.sum('balance', { where: { role: 'user' } }) || 0;

      const netReserve = parseFloat(totalDeposited) - parseFloat(totalPayouts);
      const solvencyRatio = totalUserBalance > 0
        ? ((netReserve / parseFloat(totalUserBalance)) * 100).toFixed(1)
        : '100.0';

      return ResponseHandler.success(res, {
        totalDeposited: parseFloat(totalDeposited),
        totalPayouts: parseFloat(totalPayouts),
        netReserve,
        totalUserBalance: parseFloat(totalUserBalance),
        solvencyRatio: `${solvencyRatio}%`,
        status: parseFloat(solvencyRatio) >= 100 ? 'HEALTHY' : (parseFloat(solvencyRatio) >= 50 ? 'MODERATE' : 'ATTENTION'),
      }, 'Solvency metrics calculated');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 13. Dynamic APK Release Management for Website
   */
  static async getAppRelease(req, res) {
    try {
      const setting = await SystemSetting.findOne({ where: { key: 'app_apk_release' } });
      const defaultRelease = {
        version: '1.0.0',
        version_code: 1,
        download_url: 'https://github.com/kumargupta6070/Quick_Money_App/releases/download/v1.0.0/quick-money-v1.0.0.apk',
        file_size: '28.4 MB',
        release_notes: 'Official Public Release with PhonePe Auto-Return, Real Email OTP & AES-256 Vault',
        is_active: true,
        sha256: '8a6bce1846f255b88885876928d79e6ecfcdafde46073fec59b87f7d2ece7801',
        updated_at: new Date().toISOString(),
      };
      const release = setting ? JSON.parse(setting.value) : defaultRelease;
      return ResponseHandler.success(res, release, 'Active APK release metadata');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async updateAppRelease(req, res) {
    try {
      const { version, version_code, download_url, file_size, release_notes, is_active, sha256 } = req.body;
      if (!version || !download_url) {
        return ResponseHandler.error(res, 'Version and download URL are required', 400);
      }
      const releaseData = {
        version: String(version).trim(),
        version_code: parseInt(version_code || 1, 10),
        download_url: String(download_url).trim(),
        file_size: file_size ? String(file_size).trim() : '28.4 MB',
        release_notes: release_notes ? String(release_notes).trim() : 'Latest Android APK release',
        is_active: is_active !== false,
        sha256: sha256 ? String(sha256).trim() : '',
        updated_at: new Date().toISOString(),
      };

      await SystemSetting.upsert({
        key: 'app_apk_release',
        value: JSON.stringify(releaseData),
        description: 'Active Mobile App APK Download Configuration for Landing Page Website',
      });

      // Audit Log
      await AuditLog.create({
        admin_id: req.user.id,
        action: 'UPDATE_APP_RELEASE',
        target_type: 'SystemSetting',
        target_id: 0,
        details: JSON.stringify(releaseData),
        ip_address: req.ip,
      });

      return ResponseHandler.success(res, releaseData, 'APK release published to landing page successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async deleteAppRelease(req, res) {
    try {
      const setting = await SystemSetting.findOne({ where: { key: 'app_apk_release' } });
      if (setting) {
        const parsed = JSON.parse(setting.value);
        parsed.is_active = false;
        parsed.updated_at = new Date().toISOString();
        await setting.update({ value: JSON.stringify(parsed) });
      }

      await AuditLog.create({
        admin_id: req.user.id,
        action: 'DEACTIVATE_APP_RELEASE',
        target_type: 'SystemSetting',
        target_id: 0,
        details: 'Admin deactivated APK download release from website',
        ip_address: req.ip,
      });

      return ResponseHandler.success(res, null, 'APK release disabled on landing page');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }
}

module.exports = AdminController;
