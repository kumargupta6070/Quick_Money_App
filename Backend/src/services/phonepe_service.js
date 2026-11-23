const crypto = require('crypto');
const config = require('../config/app_config');
const { Transaction, User, Order, Notification, Wallet } = require('../models');
const { encrypt, decrypt } = require('../config/encryption');
const logger = require('../utils/logger');
const ReferralService = require('./referral_service');

class PhonePeService {
  /**
   * 1. Initiate PhonePe Standard Checkout / UPI Intent Payment
   */
  static async initiatePayment({ userId, amount, orderPackageId, mobileNumber }) {
    try {
      const merchantTransactionId = `QM_${Date.now()}_${userId}`;
      const amountInPaise = Math.round(parseFloat(amount) * 100);

      const user = await User.findByPk(userId);
      if (!user) throw new Error('User not found');

      let userMobile = '9999999999';
      if (user.mobile_encrypted) {
        try {
          userMobile = decrypt(user.mobile_encrypted);
        } catch (_) {}
      }
      if (mobileNumber && mobileNumber.length >= 10) {
        userMobile = mobileNumber;
      }

      // PhonePe Standard Request Payload
      const payload = {
        merchantId: config.phonepe.merchantId,
        merchantTransactionId,
        merchantUserId: `QM_U_${userId}`,
        amount: amountInPaise,
        redirectUrl: `${config.phonepe.redirectUrl}?txnId=${merchantTransactionId}`,
        redirectMode: 'REDIRECT',
        callbackUrl: config.phonepe.callbackUrl,
        mobileNumber: userMobile,
        paymentInstrument: {
          type: 'PAY_PAGE',
        },
      };

      const base64Payload = Buffer.from(JSON.stringify(payload)).toString('base64');
      const stringToHash = base64Payload + '/pg/v1/pay' + config.phonepe.saltKey;
      const sha256 = crypto.createHash('sha256').update(stringToHash).digest('hex');
      const xVerify = `${sha256}###${config.phonepe.saltIndex}`;

      let redirectUrl = '';
      let intentUrl = '';

      try {
        // Attempt live call to PhonePe Standard API (Sandbox or Production)
        const response = await fetch(`${config.phonepe.hostUrl}/pg/v1/pay`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-VERIFY': xVerify,
          },
          body: JSON.stringify({ request: base64Payload }),
        });

        const resData = await response.json();
        logger.info(`PhonePe API response: ${JSON.stringify(resData)}`);

        if (resData.success && resData.data && resData.data.instrumentResponse) {
          const inst = resData.data.instrumentResponse;
          redirectUrl = inst.redirectInfo?.url || '';
          intentUrl = inst.intentUrl || '';
        } else if (config.phonepe.env === 'SANDBOX') {
          // Official UAT Simulator fallback in Sandbox mode
          redirectUrl = `https://mercury-uat.phonepe.com/transact/simulator?token=${merchantTransactionId}`;
          intentUrl = `phonepe://pay?pa=${config.phonepe.merchantId}@ybl&pn=QuickMoney&am=${amount}&tr=${merchantTransactionId}&cu=INR`;
        }
      } catch (networkErr) {
        logger.warn(`PhonePe network call warning (Sandbox fallback active): ${networkErr.message}`);
        if (config.phonepe.env === 'SANDBOX') {
          redirectUrl = `https://mercury-uat.phonepe.com/transact/simulator?token=${merchantTransactionId}`;
          intentUrl = `phonepe://pay?pa=${config.phonepe.merchantId}@ybl&pn=QuickMoney&am=${amount}&tr=${merchantTransactionId}&cu=INR`;
        } else {
          throw networkErr;
        }
      }

      // Record pending transaction in Database
      const tx = await Transaction.create({
        user_id: userId,
        order_id: orderPackageId || null,
        type: 'buy',
        amount: parseFloat(amount),
        profit: 0.0,
        payment_method: 'phonepe',
        payment_source_encrypted: encrypt(`UPI-${userMobile}@ibl`),
        payment_destination_encrypted: null,
        payment_reference_encrypted: encrypt(merchantTransactionId),
        status: 'pending',
      });

      return {
        success: true,
        transactionId: tx.id,
        merchantTransactionId,
        amount: parseFloat(amount),
        redirectUrl: redirectUrl || `https://mercury-uat.phonepe.com/transact/simulator?token=${merchantTransactionId}`,
        intentUrl: intentUrl || `phonepe://pay?pa=${config.phonepe.merchantId}@ybl&pn=QuickMoney&am=${amount}&tr=${merchantTransactionId}&cu=INR`,
        environment: config.phonepe.env,
      };
    } catch (err) {
      logger.error(`PhonePe initiation failed: ${err.message}`);
      throw err;
    }
  }

  /**
   * 2. Verify Incoming PhonePe Webhook Callback (Server-to-Server)
   */
  static verifyCallback(base64Response, xVerifyHeader) {
    try {
      if (!base64Response || !xVerifyHeader) {
        return { verified: false, reason: 'Missing payload or X-VERIFY signature' };
      }

      const stringToHash = base64Response + config.phonepe.saltKey;
      const calculatedHash = crypto.createHash('sha256').update(stringToHash).digest('hex');
      const expectedHeader = `${calculatedHash}###${config.phonepe.saltIndex}`;

      if (expectedHeader !== xVerifyHeader) {
        logger.warn(`PhonePe Webhook signature mismatch. Expected: ${expectedHeader}, Received: ${xVerifyHeader}`);
        return { verified: false, reason: 'Signature verification failed' };
      }

      const decoded = JSON.parse(Buffer.from(base64Response, 'base64').toString('utf8'));
      const isSuccess = decoded.code === 'PAYMENT_SUCCESS';

      return {
        verified: true,
        success: isSuccess,
        code: decoded.code,
        message: decoded.message,
        data: decoded.data,
      };
    } catch (err) {
      logger.error(`PhonePe callback verification error: ${err.message}`);
      return { verified: false, reason: err.message };
    }
  }

  /**
   * 3. Complete and Fulfill Successful PhonePe Payment (With ACID Transactions & Idempotency)
   */
  static async completePayment({ merchantTransactionId, bankUtr, providerReferenceId }) {
    try {
      const { sequelize, Transaction, User, Order, Notification } = require('../models');

      // 1. Scan for transaction matching merchantTransactionId
      const allBuyTxs = await Transaction.findAll({
        where: { type: 'buy' },
        order: [['created_at', 'DESC']],
        limit: 100,
      });

      let targetTx = null;
      for (const t of allBuyTxs) {
        try {
          const decRef = decrypt(t.payment_reference_encrypted);
          if (decRef && (decRef === merchantTransactionId || decRef.startsWith(`${merchantTransactionId}|`))) {
            targetTx = t;
            break;
          }
        } catch (_) {}
      }

      if (!targetTx) {
        logger.warn(`No transaction found for ref: ${merchantTransactionId}`);
        return { success: false, message: 'Transaction not found' };
      }

      // IDEMPOTENCY CHECK: If already completed, return success without double crediting!
      if (targetTx.status === 'completed') {
        logger.info(`Idempotent webhook received: Tx #${targetTx.id} is already completed.`);
        return {
          success: true,
          alreadySettled: true,
          transactionId: targetTx.id,
          userId: targetTx.user_id,
          amount: targetTx.amount,
        };
      }

      return await sequelize.transaction(async (t) => {
        // Atomic status transition (concurrency lock)
        const [affectedRows] = await Transaction.update(
          { status: 'completed' },
          { where: { id: targetTx.id, status: 'pending' }, transaction: t }
        );

        if (affectedRows === 0) {
          logger.info(`Concurrent settlement prevented for Tx #${targetTx.id}`);
          return { success: true, alreadySettled: true };
        }

        const finalUtr = bankUtr || providerReferenceId || `UTR-PP-${Date.now()}`;
        targetTx.payment_reference_encrypted = encrypt(`${merchantTransactionId}|UTR:${finalUtr}`);
        await targetTx.save({ transaction: t });

        // Credit User RP Balance
        const user = await User.findByPk(targetTx.user_id, { transaction: t });
        if (user) {
          user.balance = (parseFloat(user.balance) + parseFloat(targetTx.amount)).toFixed(2);
          await user.save({ transaction: t });
        }

        // If tied to an RP Order package, activate it
        if (targetTx.order_id) {
          const order = await Order.findByPk(targetTx.order_id, { transaction: t });
          if (order) {
            order.buyer_id = targetTx.user_id;
            order.status = 'received';
            await order.save({ transaction: t });
          }
        }

        // Distribute 3-Level Referral Rebates to Sponsors
        try {
          await ReferralService.distributeRebate(targetTx.user_id, parseFloat(targetTx.amount), t);
        } catch (refErr) {
          logger.warn(`Referral distribution notice: ${refErr.message}`);
        }

        // Push in-app confirmation notification to user
        await Notification.create({
          user_id: targetTx.user_id,
          title: 'PhonePe Payment Confirmed! 🚀',
          message: `Your payment of ₹${parseFloat(targetTx.amount).toFixed(2)} via PhonePe UPI has been confirmed. Bank UTR: ${finalUtr}. RP package activated!`,
          type: 'order',
          is_read: false,
        }, { transaction: t });

        // Dispatch notification to SuperAdmins
        try {
          const NotificationService = require('./notification_service');
          await NotificationService.notifyAdmins({
            title: 'Payment Confirmed 💰',
            message: `User #${targetTx.user_id} paid ₹${parseFloat(targetTx.amount).toFixed(2)} via PhonePe. Bank UTR: ${finalUtr}.`,
            type: 'order',
          });
        } catch (_) {}

        logger.info(`Payment fulfilled successfully for Tx: ${targetTx.id}, User: ${targetTx.user_id}`);
        return {
          success: true,
          transactionId: targetTx.id,
          userId: targetTx.user_id,
          amount: targetTx.amount,
          bankUtr: finalUtr,
        };
      });
    } catch (err) {
      logger.error(`Error completing PhonePe payment: ${err.message}`);
      throw err;
    }
  }

  /**
   * 4. Check Payment Status from PhonePe PG
   */
  static async checkStatus(merchantTransactionId) {
    try {
      const stringToHash = `/pg/v1/status/${config.phonepe.merchantId}/${merchantTransactionId}` + config.phonepe.saltKey;
      const sha256 = crypto.createHash('sha256').update(stringToHash).digest('hex');
      const xVerify = `${sha256}###${config.phonepe.saltIndex}`;

      const response = await fetch(
        `${config.phonepe.hostUrl}/pg/v1/status/${config.phonepe.merchantId}/${merchantTransactionId}`,
        {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
            'X-VERIFY': xVerify,
            'X-MERCHANT-ID': config.phonepe.merchantId,
          },
        }
      );

      const resData = await response.json();
      return resData;
    } catch (err) {
      logger.error(`PhonePe status check error: ${err.message}`);
      return { success: false, message: err.message };
    }
  }
}

module.exports = PhonePeService;
