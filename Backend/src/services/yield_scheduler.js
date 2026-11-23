const { Order, User, Transaction, DailyProfit, Notification, SystemSetting } = require('../models');
const AutoPayoutService = require('./auto_payout_service');
const logger = require('../utils/logger');

class YieldScheduler {
  static _intervalId = null;

  /**
   * Run one complete daily yield cycle for all active RP orders
   */
  static async runDailyCycle() {
    try {
      logger.info('=== Starting Automated Daily Yield Distribution Cycle ===');

      // 1. Get daily yield rate and market status
      let dailyYieldRate = 0.025; // Default 2.5%
      let isMarketOnline = true;

      try {
        const rateSetting = await SystemSetting.findOne({ where: { key: 'daily_yield_rate' } });
        if (rateSetting && parseFloat(rateSetting.value) > 0) {
          dailyYieldRate = parseFloat(rateSetting.value);
        }
        const statusSetting = await SystemSetting.findOne({ where: { key: 'market_status' } });
        if (statusSetting && statusSetting.value !== 'ONLINE') {
          isMarketOnline = false;
        }
      } catch (err) {
        logger.warn(`Could not load yield settings: ${err.message}. Using default 2.5%`);
      }

      if (!isMarketOnline) {
        logger.info('Yield cycle skipped: Market trading status is OFFLINE.');
        return { success: false, reason: 'Market is OFFLINE' };
      }

      const todayStr = new Date().toISOString().split('T')[0];

      // 2. Query all active received orders with a buyer
      const activeOrders = await Order.findAll({
        where: { status: 'received' },
      });

      let totalYieldDistributed = 0.0;
      let ordersCredited = 0;

      for (const order of activeOrders) {
        if (!order.buyer_id) continue;

        const buyer = await User.findByPk(order.buyer_id);
        if (!buyer) continue;

        const orderAmount = parseFloat(order.order_amount || 0);
        if (orderAmount <= 0) continue;

        const profitAmount = parseFloat((orderAmount * dailyYieldRate).toFixed(2));
        if (profitAmount <= 0) continue;

        // Credit to user balance
        buyer.balance = (parseFloat(buyer.balance || 0) + profitAmount).toFixed(2);
        await buyer.save();

        // Create profit transaction
        await Transaction.create({
          user_id: buyer.id,
          order_id: order.id,
          type: 'profit',
          amount: profitAmount,
          profit: profitAmount,
          payment_method: 'trading_yield',
          payment_source_encrypted: null,
          payment_destination_encrypted: null,
          status: 'completed',
        });

        // Upsert DailyProfit record for today
        let dailyRecord = await DailyProfit.findOne({
          where: { user_id: buyer.id, profit_date: todayStr },
        });

        if (dailyRecord) {
          dailyRecord.total_income = (parseFloat(dailyRecord.total_income || 0) + profitAmount).toFixed(2);
          dailyRecord.brokerage = (parseFloat(dailyRecord.brokerage || 0) + profitAmount).toFixed(2);
          await dailyRecord.save();
        } else {
          await DailyProfit.create({
            user_id: buyer.id,
            profit_date: todayStr,
            total_income: profitAmount,
            purchase_number: 0,
            purchase_amount: 0.0,
            brokerage: profitAmount,
            team_rebates: 0.0,
            subordinate_rebates: 0.0,
            usdt_recharge: 0.0,
            trx_recharge: 0.0,
            sell_number: 0,
            sell_amount: 0.0,
            activity_reward: 0.0,
            other_reward: 0.0,
          });
        }

        // Notification to user
        await Notification.create({
          user_id: buyer.id,
          title: 'Daily Yield Credited! ⚡',
          message: `Daily return of ₹${profitAmount.toFixed(2)} (${(dailyYieldRate * 100).toFixed(1)}%) credited for ${order.level} RP Order #${order.id}.`,
          type: 'profit',
          is_read: false,
        });

        totalYieldDistributed += profitAmount;
        ordersCredited++;
      }

      logger.info(`Yield distribution completed: Credited ₹${totalYieldDistributed.toFixed(2)} across ${ordersCredited} active orders.`);

      // 3. Trigger auto-payout check for users reaching >= ₹100 threshold
      const autoPayoutResult = await AutoPayoutService.processEligiblePayouts();

      return {
        success: true,
        ordersCredited,
        totalYieldDistributed,
        rateApplied: dailyYieldRate,
        autoPayout: autoPayoutResult,
      };
    } catch (err) {
      logger.error(`Error during YieldScheduler cycle: ${err.message}`);
      throw err;
    }
  }

  /**
   * Start recurring background timer (every 24 hours, checked hourly)
   */
  static startScheduler() {
    if (this._intervalId) return;

    logger.info('Daily Yield Background Scheduler initialized (Hourly check active).');

    // Run hourly check to see if today's distribution is needed
    this._intervalId = setInterval(async () => {
      try {
        const now = new Date();
        // Trigger at 00:05 AM IST (18:35 UTC previous day or 00:05 local)
        if (now.getHours() === 0 && now.getMinutes() < 15) {
          await this.runDailyCycle();
        }
      } catch (err) {
        logger.error(`Background scheduler execution error: ${err.message}`);
      }
    }, 60 * 60 * 1000); // Check every 60 minutes
  }

  static stopScheduler() {
    if (this._intervalId) {
      clearInterval(this._intervalId);
      this._intervalId = null;
    }
  }
}

module.exports = YieldScheduler;
