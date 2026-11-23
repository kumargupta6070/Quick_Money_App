const { Referral, User } = require('../models');

class ReferralService {
  /**
   * Distributes rebates across 3 levels:
   * Level 1: 5%
   * Level 2: 3%
   * Level 3: 1%
   * Logs explicit audit Transaction records & sends push notifications.
   */
  static async distributeRebate(userId, orderAmount, dbTx = null) {
    const { Transaction, Notification } = require('../models');
    const user = await User.findByPk(userId, dbTx ? { transaction: dbTx } : {});
    if (!user || !user.referred_by) return;

    const opt = dbTx ? { transaction: dbTx } : {};

    // Find Level 1 referrer
    const l1User = await User.findOne({ where: { invite_code: user.referred_by }, ...opt });
    if (!l1User) return;

    const l1Rebate = parseFloat((orderAmount * 0.05).toFixed(2));
    if (l1Rebate > 0) {
      await l1User.increment('balance', { by: l1Rebate, ...opt });
      await Transaction.create({
        user_id: l1User.id,
        type: 'rebate',
        amount: l1Rebate,
        profit: l1Rebate,
        payment_method: 'referral_bonus',
        status: 'completed',
      }, opt);
      await Notification.create({
        user_id: l1User.id,
        title: 'Level 1 Rebate Credited! 🎁',
        message: `You earned ₹${l1Rebate.toFixed(2)} (5%) rebate from a Direct Team trade!`,
        type: 'reward',
        is_read: false,
      }, opt);
    }

    // Level 2
    if (l1User.referred_by) {
      const l2User = await User.findOne({ where: { invite_code: l1User.referred_by }, ...opt });
      if (l2User) {
        const l2Rebate = parseFloat((orderAmount * 0.03).toFixed(2));
        if (l2Rebate > 0) {
          await l2User.increment('balance', { by: l2Rebate, ...opt });
          await Transaction.create({
            user_id: l2User.id,
            type: 'rebate',
            amount: l2Rebate,
            profit: l2Rebate,
            payment_method: 'referral_bonus',
            status: 'completed',
          }, opt);
          await Notification.create({
            user_id: l2User.id,
            title: 'Level 2 Rebate Credited! 🎁',
            message: `You earned ₹${l2Rebate.toFixed(2)} (3%) rebate from an L2 Team trade!`,
            type: 'reward',
            is_read: false,
          }, opt);
        }

        // Level 3
        if (l2User.referred_by) {
          const l3User = await User.findOne({ where: { invite_code: l2User.referred_by }, ...opt });
          if (l3User) {
            const l3Rebate = parseFloat((orderAmount * 0.01).toFixed(2));
            if (l3Rebate > 0) {
              await l3User.increment('balance', { by: l3Rebate, ...opt });
              await Transaction.create({
                user_id: l3User.id,
                type: 'rebate',
                amount: l3Rebate,
                profit: l3Rebate,
                payment_method: 'referral_bonus',
                status: 'completed',
              }, opt);
              await Notification.create({
                user_id: l3User.id,
                title: 'Level 3 Rebate Credited! 🎁',
                message: `You earned ₹${l3Rebate.toFixed(2)} (1%) rebate from an L3 Network trade!`,
                type: 'reward',
                is_read: false,
              }, opt);
            }
          }
        }
      }
    }
  }

  static async getTeamOverview(userId) {
    const user = await User.findByPk(userId);
    if (!user) {
      return {
        totalEarnings: 0.0,
        level1Earnings: 0.0,
        level2Earnings: 0.0,
        level3Earnings: 0.0,
        dailyVolume: 0.0,
        level1Members: 0,
        level2Members: 0,
        level3Members: 0,
        level1Percent: '5%',
        level2Percent: '3%',
        level3Percent: '1%',
      };
    }

    const { Transaction, sequelize } = require('../models');
    const { Op } = require('sequelize');

    // 1. Level 1 Users (Directly referred by user.invite_code)
    const l1Users = await User.findAll({ where: { referred_by: user.invite_code } });
    const l1Count = l1Users.length;
    const l1Codes = l1Users.map((u) => u.invite_code);
    const l1UserIds = l1Users.map((u) => u.id);

    // 2. Level 2 Users (Referred by L1 users)
    let l2Users = [];
    if (l1Codes.length > 0) {
        l2Users = await User.findAll({
          where: { referred_by: { [Op.in]: l1Codes } },
        });
      }
    const l2Count = l2Users.length;
      const l2Codes = l2Users.map((u) => u.invite_code);
      const l2UserIds = l2Users.map((u) => u.id);

          // 3. Level 3 Users (Referred by L2 users)
          let l3Users =[];
          if(l2Codes.length > 0) {
            l3Users = await User.findAll({
              where: { referred_by: { [Op.in]: l2Codes } },
            });
      }
      const l3Count = l3Users.length;
      const l3UserIds = l3Users.map((u) => u.id);

      // 4. Calculate Team Volumes & Tier-wise Earnings
      const allTeamUserIds = [...l1UserIds, ...l2UserIds, ...l3UserIds];
      let dailyVolume = 0.0;
      let l1OrdersSum = 0.0;
      let l2OrdersSum = 0.0;
      let l3OrdersSum = 0.0;

      if (allTeamUserIds.length > 0) {
        const todayStart = new Date();
        todayStart.setHours(0, 0, 0, 0);

        const todayVolume = await Transaction.sum('amount', {
          where: {
            user_id: { [Op.in]: allTeamUserIds },
            type: 'buy',
            created_at: { [Op.gte]: todayStart },
          },
        });
        dailyVolume = parseFloat(todayVolume || 0);

        if (l1UserIds.length > 0) {
          const sum1 = await Transaction.sum('amount', {
            where: { user_id: { [Op.in]: l1UserIds }, type: 'buy' },
          });
          l1OrdersSum = parseFloat(sum1 || 0);
        }

        if (l2UserIds.length > 0) {
          const sum2 = await Transaction.sum('amount', {
            where: { user_id: { [Op.in]: l2UserIds }, type: 'buy' },
          });
          l2OrdersSum = parseFloat(sum2 || 0);
        }

        if (l3UserIds.length > 0) {
          const sum3 = await Transaction.sum('amount', {
            where: { user_id: { [Op.in]: l3UserIds }, type: 'buy' },
          });
          l3OrdersSum = parseFloat(sum3 || 0);
        }
      }

        const level1Earnings = parseFloat((l1OrdersSum * 0.05).toFixed(2));
        const level2Earnings = parseFloat((l2OrdersSum * 0.03).toFixed(2));
        const level3Earnings = parseFloat((l3OrdersSum * 0.01).toFixed(2));

        const directRebateTx = await Transaction.sum('profit', {
          where: { user_id: userId, type: 'rebate' },
        });
        const totalEarnings = parseFloat(
          (directRebateTx != null && directRebateTx > 0)
            ? directRebateTx
            : (level1Earnings + level2Earnings + level3Earnings)
        );

        return {
          totalEarnings: parseFloat(totalEarnings.toFixed(2)),
          level1Earnings,
          level2Earnings,
          level3Earnings,
          dailyVolume: parseFloat(dailyVolume.toFixed(2)),
          level1Members: l1Count,
          level2Members: l2Count,
          level3Members: l3Count,
          level1Percent: '5%',
          level2Percent: '3%',
          level3Percent: '1%',
        };
      }

  /**
   * Retrieves detailed members list for a specific tier (L1, L2, L3)
   */
  static async getTierMembers(userId, tier = 'L1') {
    const user = await User.findByPk(userId);
    if (!user) return [];

    const { Transaction } = require('../models');
    const { decrypt } = require('../config/encryption');
    const { Op } = require('sequelize');

    const requestedTier = (tier || 'L1').toUpperCase();
    let targetUsers = [];
    let commissionRate = 0.05;

    // 1. Direct L1
    const l1Users = await User.findAll({ where: { referred_by: user.invite_code } });

    if (requestedTier === 'L1') {
      targetUsers = l1Users;
      commissionRate = 0.05;
    } else if (requestedTier === 'L2') {
      commissionRate = 0.03;
      const l1Codes = l1Users.map((u) => u.invite_code);
      if (l1Codes.length > 0) {
        targetUsers = await User.findAll({ where: { referred_by: { [Op.in]: l1Codes } } });
      }
    } else if (requestedTier === 'L3') {
      commissionRate = 0.01;
      const l1Codes = l1Users.map((u) => u.invite_code);
      if (l1Codes.length > 0) {
        const l2Users = await User.findAll({ where: { referred_by: { [Op.in]: l1Codes } } });
        const l2Codes = l2Users.map((u) => u.invite_code);
        if (l2Codes.length > 0) {
          targetUsers = await User.findAll({ where: { referred_by: { [Op.in]: l2Codes } } });
        }
      }
    }

    const members = [];
    for (const u of targetUsers) {
      let mobile = '98****1234';
      if (u.mobile_encrypted) {
        try {
          const raw = decrypt(u.mobile_encrypted);
          if (raw && raw.length >= 10) {
            mobile = `${raw.substring(0, 2)}****${raw.substring(raw.length - 4)}`;
          }
        } catch (_) {}
      }

      const sumVolume = await Transaction.sum('amount', {
        where: { user_id: u.id, type: 'buy' },
      });
      const tradeVolume = parseFloat(sumVolume || 0);
      const earned = parseFloat((tradeVolume * commissionRate).toFixed(2));

      members.push({
        id: u.id,
        maskedMobile: mobile,
        inviteCode: u.invite_code,
        tier: requestedTier,
        commissionPercent: `${(commissionRate * 100).toFixed(0)}%`,
        tradeVolume,
        commissionEarned: earned,
        joinedAt: u.created_at,
        status: u.status || 'active',
      });
    }

    return members;
  }
}

module.exports = ReferralService;

