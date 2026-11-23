const { User, Wallet, Transaction, Notification, DailyProfit, sequelize } = require('../models');
const { Op } = require('sequelize');

const TASK_CONFIGS = {
  verify_mobile: {
    id: 'verify_mobile',
    title: 'Verify Mobile Number',
    subtitle: 'Primary account phone verification',
    reward: 10.0,
    rewardText: '₹10.00 RP',
    navigationRoute: null,
  },
  bind_phonepe: {
    id: 'bind_phonepe',
    title: 'Bind PhonePe UPI Address',
    subtitle: 'Enables automatic ₹100 returns to PhonePe',
    reward: 20.0,
    rewardText: '₹20.00 RP',
    navigationRoute: '/bind-payment',
  },
  first_order: {
    id: 'first_order',
    title: 'Receive First L1 RP Order',
    subtitle: 'Start with ₹100 - ₹300 minimum order trade',
    reward: 20.0,
    rewardText: '₹20.00 RP',
    navigationRoute: '/buy-rp',
  },
  first_invite: {
    id: 'first_invite',
    title: 'Invite First Team Member',
    subtitle: 'Unlock lifetime 3-level rebate earnings',
    reward: 50.0,
    rewardText: '₹50.00 RP',
    navigationRoute: '/team',
  },
};

class RewardService {
  /**
   * Retrieves live newbie reward milestones for a user.
   */
  static async getNewbieRewards(userId) {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new Error('User not found');
    }

    // 1. Check wallet binding
    const wallet = await Wallet.findOne({
      where: { user_id: userId, status: 'active' },
    });
    const isWalletBound = !!wallet;

    // 2. Check first buy order
    const buyCount = await Transaction.count({
      where: { user_id: userId, type: 'buy' },
    });
    const hasPlacedOrder = buyCount > 0;

    // 3. Check first referral
    const inviteCount = await User.count({
      where: { referred_by: user.invite_code },
    });
    const hasInvited = inviteCount > 0;

    // 4. Check already claimed tasks
    const claimedTxs = await Transaction.findAll({
      where: { user_id: userId, type: 'reward' },
    });
    const claimedTaskIds = new Set(
      claimedTxs
        .map((tx) => tx.payment_reference_encrypted)
        .filter((ref) => ref && ref.startsWith('reward_task:'))
        .map((ref) => ref.replace('reward_task:', ''))
    );

    const taskKeys = ['verify_mobile', 'bind_phonepe', 'first_order', 'first_invite'];
    const tasks = taskKeys.map((key) => {
      const cfg = TASK_CONFIGS[key];
      const isClaimed = claimedTaskIds.has(key);

      let isEligible = false;
      if (key === 'verify_mobile') {
        isEligible = true; // Registered and authenticated
      } else if (key === 'bind_phonepe') {
        isEligible = isWalletBound;
      } else if (key === 'first_order') {
        isEligible = hasPlacedOrder;
      } else if (key === 'first_invite') {
        isEligible = hasInvited;
      }

      let actionType = 'navigate';
      if (isClaimed) {
        actionType = 'claimed';
      } else if (isEligible) {
        actionType = 'claim';
      } else {
        actionType = 'navigate';
      }

      return {
        id: cfg.id,
        title: cfg.title,
        subtitle: cfg.subtitle,
        reward: cfg.reward,
        rewardText: cfg.rewardText,
        isEligible,
        isClaimed,
        actionType,
        navigationRoute: cfg.navigationRoute,
      };
    });

    const completedCount = tasks.filter((t) => t.isClaimed).length;
    const progressPercent = Math.min(100, Math.round((completedCount / tasks.length) * 100));

    return {
      completedCount,
      totalTasks: tasks.length,
      progressPercent,
      welcomeBonusAmount: 50.0,
      tasks,
    };
  }

  /**
   * Claims a newbie milestone reward and credits the user's balance atomically.
   */
  static async claimReward(userId, taskId) {
    const cfg = TASK_CONFIGS[taskId];
    if (!cfg) {
      throw new Error(`Invalid milestone task: ${taskId}`);
    }

    const user = await User.findByPk(userId);
    if (!user) {
      throw new Error('User not found');
    }

    // Check if already claimed
    const existingClaim = await Transaction.findOne({
      where: {
        user_id: userId,
        type: 'reward',
        payment_reference_encrypted: `reward_task:${taskId}`,
      },
    });
    if (existingClaim) {
      throw new Error('You have already claimed this milestone reward.');
    }

    // Verify task eligibility
    if (taskId === 'bind_phonepe') {
      const wallet = await Wallet.findOne({
        where: { user_id: userId, status: 'active' },
      });
      if (!wallet) {
        throw new Error('Please bind your PhonePe UPI address first to claim this reward.');
      }
    } else if (taskId === 'first_order') {
      const buyCount = await Transaction.count({
        where: { user_id: userId, type: 'buy' },
      });
      if (buyCount === 0) {
        throw new Error('Please complete your first RP order to claim this reward.');
      }
    } else if (taskId === 'first_invite') {
      const inviteCount = await User.count({
        where: { referred_by: user.invite_code },
      });
      if (inviteCount === 0) {
        throw new Error('Please invite at least 1 team member to claim this reward.');
      }
    }

    // Execute credit and transaction recording
    const t = await sequelize.transaction();
    try {
      await user.increment('balance', { by: cfg.reward, transaction: t });
      await user.reload({ transaction: t });

      await Transaction.create(
        {
          user_id: userId,
          type: 'reward',
          amount: cfg.reward,
          profit: cfg.reward,
          payment_method: 'phonepe',
          payment_reference_encrypted: `reward_task:${taskId}`,
          status: 'completed',
        },
        { transaction: t }
      );

      await Notification.create(
        {
          user_id: userId,
          title: 'Milestone Reward Claimed! 🎁',
          message: `₹${cfg.reward.toFixed(2)} RP reward for "${cfg.title}" has been credited to your balance.`,
          type: 'reward',
          is_read: false,
        },
        { transaction: t }
      );

      // Increment daily profit activity reward if record exists for today
      const today = new Date().toISOString().split('T')[0];
      const profitRecord = await DailyProfit.findOne({
        where: { user_id: userId, profit_date: today },
        transaction: t,
      });
      if (profitRecord) {
        await profitRecord.increment('activity_reward', {
          by: cfg.reward,
          transaction: t,
        });
      }

      await t.commit();

      return {
        taskId,
        rewardAmount: cfg.reward,
        newBalance: parseFloat(user.balance),
        message: `₹${cfg.reward.toFixed(2)} RP reward claimed successfully!`,
      };
    } catch (err) {
      await t.rollback();
      throw err;
    }
  }
}

module.exports = RewardService;
