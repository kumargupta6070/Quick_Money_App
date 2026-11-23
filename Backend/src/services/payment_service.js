const { Transaction, Wallet, User } = require('../models');
const { encrypt, decrypt } = require('../utils/crypto_helper');
const config = require('../config/app_config');

class PaymentService {
  /**
   * Records initial deposit from user's PhonePe UPI.
   */
  static async recordDeposit({ userId, amount, upiId, paymentMethod = 'phonepe' }) {
    const encryptedUpi = encrypt(upiId);
    const refId = `DEP-${Date.now()}`;

    const tx = await Transaction.create({
      user_id: userId,
      type: 'deposit',
      amount,
      profit: 0.0,
      payment_method: paymentMethod,
      payment_source_encrypted: encryptedUpi,
      payment_destination_encrypted: null,
      payment_reference_encrypted: encrypt(refId),
      status: 'completed',
    });

    // Increment user balance
    const user = await User.findByPk(userId);
    if (user) {
      await user.increment('balance', { by: amount });
    }

    return {
      transactionId: tx.id,
      referenceId: refId,
      amount,
      status: 'completed',
    };
  }

  /**
   * Checks if user profit >= threshold (₹100).
   * If yes, automatically initiates payout return to the original PhonePe UPI source.
   */
  static async checkAndProcessProfitReturn(userId) {
    const user = await User.findByPk(userId);
    if (!user) throw new Error('User not found');

    // Find user's last successful deposit to know source PhonePe UPI
    const lastDeposit = await Transaction.findOne({
      where: { user_id: userId, type: 'deposit' },
      order: [['created_at', 'DESC']],
    });

    // Or check bound PhonePe wallet
    const boundWallet = await Wallet.findOne({
      where: { user_id: userId, status: 'active' },
    });

    const destinationUpi =
      (lastDeposit && lastDeposit.payment_source_encrypted) ||
      (boundWallet && boundWallet.upi_id_encrypted);

    if (!destinationUpi) {
      return {
        triggered: false,
        reason: 'No PhonePe destination found for payout return',
      };
    }

    // Calculate total accumulated profit from recent orders
    const orderProfits = await Transaction.sum('profit', {
      where: { user_id: userId, type: 'buy' },
    });

    const accumulatedProfit = parseFloat(orderProfits || 0);

    if (accumulatedProfit >= config.profitReturnThreshold) {
      const payoutAmount = accumulatedProfit;
      const refId = `PAYOUT-${Date.now()}`;

      const payoutTx = await Transaction.create({
        user_id: userId,
        type: 'payout',
        amount: payoutAmount,
        profit: accumulatedProfit,
        payment_method: 'phonepe',
        payment_source_encrypted: null,
        payment_destination_encrypted: destinationUpi,
        payment_reference_encrypted: encrypt(refId),
        status: 'completed',
      });

      return {
        triggered: true,
        transactionId: payoutTx.id,
        referenceId: refId,
        payoutAmount,
        returnedToUpi: decrypt(destinationUpi),
        status: 'completed',
      };
    }

    return {
      triggered: false,
      currentProfit: accumulatedProfit,
      threshold: config.profitReturnThreshold,
      remainingToTrigger: config.profitReturnThreshold - accumulatedProfit,
    };
  }
}

module.exports = PaymentService;

