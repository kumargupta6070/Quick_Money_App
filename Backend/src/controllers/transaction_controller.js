const { Transaction, User, Wallet } = require('../models');
const ResponseHandler = require('../utils/response_handler');
const { encrypt, decrypt } = require('../utils/crypto_helper');

class TransactionController {
  static async getHistory(req, res) {
    try {
      const list = await Transaction.findAll({
        where: { user_id: req.user.id },
        order: [['created_at', 'DESC']],
        limit: 50,
      });

      const formatted = list.map((tx) => ({
        id: tx.id,
        type: tx.type,
        amount: tx.amount,
        profit: tx.profit,
        payment_method: tx.payment_method,
        payment_source: decrypt(tx.payment_source_encrypted),
        payment_destination: decrypt(tx.payment_destination_encrypted),
        status: tx.status,
        created_at: tx.created_at,
      }));

      return ResponseHandler.success(res, formatted);
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async requestPayout(req, res) {
    try {
      const { amount } = req.body;
      const { sequelize, User, Wallet, Transaction } = require('../models');
      const { Op } = require('sequelize');

      const user = await User.findByPk(req.user.id);
      if (!user) return ResponseHandler.error(res, 'User not found', 404);

      const payoutAmount = parseFloat(amount || user.balance);
      if (isNaN(payoutAmount) || payoutAmount < 100) {
        return ResponseHandler.error(res, 'Minimum return payout limit is ₹100.00', 400);
      }

      const boundWallet = await Wallet.findOne({
        where: { user_id: req.user.id, status: 'active' },
      });
      if (!boundWallet) {
        return ResponseHandler.error(res, 'Please bind your PhonePe UPI wallet first before requesting payout', 400);
      }

      // ACID Atomic Decrement with Concurrency Protection (Prevents Double-Spending)
      const result = await sequelize.transaction(async (t) => {
        const [affectedRows] = await User.update(
          { balance: sequelize.literal(`balance - ${payoutAmount}`) },
          {
            where: {
              id: req.user.id,
              balance: { [Op.gte]: payoutAmount },
            },
            transaction: t,
          }
        );

        if (affectedRows === 0) {
          throw new Error('Insufficient wallet balance or concurrent transaction in progress.');
        }

        const refId = `PAYOUT-${Date.now()}-${req.user.id}`;
        const tx = await Transaction.create({
          user_id: req.user.id,
          type: 'payout',
          amount: payoutAmount,
          profit: 0.0,
          payment_method: boundWallet.payment_app || 'phonepe',
          payment_source_encrypted: null,
          payment_destination_encrypted: boundWallet.upi_id_encrypted,
          payment_reference_encrypted: encrypt(refId),
          status: 'pending', // Queued in Admin Payout Desk for instant 1-tap settlement
        }, { transaction: t });

        return { tx, refId };
      });

      // Dispatch notifications to User and Admin
      try {
        const NotificationService = require('../services/notification_service');
        const userVpa = decrypt(boundWallet.upi_id_encrypted);
        await Promise.allSettled([
          NotificationService.send({
            userId: user.id,
            title: 'Payout Request Queued 💸',
            message: `Your return payout of ₹${payoutAmount.toFixed(2)} to ${userVpa} has been submitted. Status: In Queue.`,
            type: 'order',
          }),
          NotificationService.notifyAdmins({
            title: 'New Payout Requested 💸',
            message: `User ${user.email} (ID: #${user.id}) requested payout of ₹${payoutAmount.toFixed(2)} to ${userVpa}. Ref: ${result.refId}`,
            type: 'system',
          }),
        ]);
      } catch (_) {}

      return ResponseHandler.success(res, {
        transactionId: result.tx.id,
        referenceId: result.refId,
        amount: payoutAmount,
        upiId: decrypt(boundWallet.upi_id_encrypted),
        status: 'pending',
      }, 'Return payout queued successfully for PhonePe settlement!');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 400);
    }
  }
}

module.exports = TransactionController;

