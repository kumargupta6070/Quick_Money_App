const { User, Wallet, Transaction, Notification, SystemSetting } = require('../models');
const { encrypt } = require('../config/encryption');
const logger = require('../utils/logger');

class AutoPayoutService {
  /**
   * Evaluates all users with balance >= threshold and initiates auto-payout to their PhonePe UPI.
   */
  static async processEligiblePayouts() {
    try {
      // 1. Get threshold & market status from settings
      let threshold = 100.0;
      let isMarketOnline = true;

      try {
        const thresholdSetting = await SystemSetting.findOne({ where: { key: 'profit_return_threshold' } });
        if (thresholdSetting && parseFloat(thresholdSetting.value) > 0) {
          threshold = parseFloat(thresholdSetting.value);
        }
        const statusSetting = await SystemSetting.findOne({ where: { key: 'market_status' } });
        if (statusSetting && statusSetting.value !== 'ONLINE') {
          isMarketOnline = false;
        }
      } catch (err) {
        logger.warn(`Could not load payout settings: ${err.message}. Using default ₹100.00`);
      }

      if (!isMarketOnline) {
        logger.info('Auto-payout skipped: Market trading status is currently PAUSED / OFFLINE.');
        return { processed: 0, reason: 'Market is OFFLINE' };
      }

      // 2. Query users with balance >= threshold
      const eligibleUsers = await User.findAll({
        where: { role: 'user' },
      });

      let payoutCount = 0;
      const results = [];

      for (const user of eligibleUsers) {
        const bal = parseFloat(user.balance || 0);
        if (bal < threshold) continue;

        // Check if user has an active bound wallet
        const boundWallet = await Wallet.findOne({
          where: { user_id: user.id, status: 'active' },
        });

        if (!boundWallet) {
          logger.info(`User #${user.id} has reached ₹${bal.toFixed(2)} balance, but no bound PhonePe wallet found.`);
          continue;
        }

        // Deduct threshold from user balance
        await user.decrement('balance', { by: threshold });

        // Record payout transaction
        const refId = `AUTO-PP-${Date.now()}-${user.id}`;
        const tx = await Transaction.create({
          user_id: user.id,
          type: 'payout',
          amount: threshold,
          profit: 0.0,
          payment_method: boundWallet.payment_app || 'phonepe',
          payment_source_encrypted: null,
          payment_destination_encrypted: boundWallet.upi_id_encrypted,
          payment_reference_encrypted: encrypt(refId),
          status: 'pending', // Queued in Super Admin Payout Desk for instant 1-tap UTR settlement
        });

        // Push confirmation notification
        await Notification.create({
          user_id: user.id,
          title: '🎉 ₹100 PhonePe Auto-Return Initiated!',
          message: `Congratulations! Your trading profit reached ₹${threshold.toFixed(2)}. Automatic payout has been queued to your bound PhonePe UPI ID.`,
          type: 'payout',
          is_read: false,
        });

        payoutCount++;
        results.push({
          userId: user.id,
          amount: threshold,
          transactionId: tx.id,
          referenceId: refId,
        });

        logger.info(`Auto-payout queued for User #${user.id}: ₹${threshold.toFixed(2)} (Ref: ${refId})`);
      }

      return {
        success: true,
        processedCount: payoutCount,
        threshold,
        results,
      };
    } catch (err) {
      logger.error(`Error in AutoPayoutService: ${err.message}`);
      throw err;
    }
  }
}

module.exports = AutoPayoutService;
