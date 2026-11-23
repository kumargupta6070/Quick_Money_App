const PhonePeService = require('../services/phonepe_service');
const ResponseHandler = require('../utils/response_handler');
const logger = require('../utils/logger');
const { Transaction } = require('../models');
const { decrypt } = require('../config/encryption');

class PhonePeController {
  /**
   * 1. Initiate a PhonePe Buy RP payment (Native UPI Intent / Web Checkout)
   * POST /api/v1/payments/phonepe/initiate
   */
  static async initiatePayment(req, res) {
    try {
      const { amount, orderPackageId, mobileNumber } = req.body;
      const userId = req.user.id;

      if (!amount || parseFloat(amount) <= 0) {
        return ResponseHandler.error(res, 'Valid payment amount is required', 400);
      }

      const result = await PhonePeService.initiatePayment({
        userId,
        amount: parseFloat(amount),
        orderPackageId: orderPackageId ? parseInt(orderPackageId, 10) : null,
        mobileNumber,
      });

      return ResponseHandler.success(
        res,
        result,
        'PhonePe payment initiated successfully. Launching UPI Intent...'
      );
    } catch (err) {
      logger.error(`Initiate payment error: ${err.message}`);
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 2. PhonePe Server-to-Server Webhook / Callback Handler
   * POST /api/v1/payments/phonepe/callback
   */
  static async handleWebhook(req, res) {
    try {
      const { response: base64Response } = req.body;
      const xVerify = req.headers['x-verify'];

      logger.info(`Received PhonePe webhook with X-VERIFY: ${xVerify}`);

      const verification = PhonePeService.verifyCallback(base64Response, xVerify);
      if (!verification.verified) {
        logger.warn(`PhonePe callback rejected: ${verification.reason}`);
        return res.status(400).json({ success: false, message: verification.reason });
      }

      if (verification.success && verification.data) {
        const { merchantTransactionId, paymentInstrument, providerReferenceId } = verification.data;
        const bankUtr = paymentInstrument?.utr || providerReferenceId;

        await PhonePeService.completePayment({
          merchantTransactionId,
          bankUtr,
          providerReferenceId,
        });
      }

      return res.status(200).json({
        success: true,
        code: 'SUCCESS',
        message: 'Callback verified and processed successfully',
      });
    } catch (err) {
      logger.error(`Webhook processing error: ${err.message}`);
      return res.status(500).json({ success: false, message: err.message });
    }
  }

  /**
   * 3. Check Payment Status
   * GET /api/v1/payments/phonepe/status/:txnId
   */
  static async checkStatus(req, res) {
    try {
      const { txnId } = req.params;

      // 1. Check local DB status first
      const pendingTxs = await Transaction.findAll({
        where: { type: 'buy' },
        limit: 100,
        order: [['created_at', 'DESC']],
      });

      let found = null;
      for (const t of pendingTxs) {
        try {
          const dec = decrypt(t.payment_reference_encrypted);
          if (dec && dec.includes(txnId)) {
            found = t;
            break;
          }
        } catch (_) {}
      }

      if (found && found.status === 'completed') {
        return ResponseHandler.success(res, {
          status: 'COMPLETED',
          transactionId: found.id,
          amount: found.amount,
          message: 'Payment completed and RP order active',
        });
      }

      // 2. Query PhonePe Gateway live status
      const gatewayStatus = await PhonePeService.checkStatus(txnId);
      if (gatewayStatus.success && gatewayStatus.code === 'PAYMENT_SUCCESS') {
        // Auto-fulfill if not yet fulfilled
        await PhonePeService.completePayment({
          merchantTransactionId: txnId,
          bankUtr: gatewayStatus.data?.paymentInstrument?.utr,
          providerReferenceId: gatewayStatus.data?.providerReferenceId,
        });

        return ResponseHandler.success(res, {
          status: 'COMPLETED',
          amount: gatewayStatus.data?.amount ? gatewayStatus.data.amount / 100 : 0,
          message: 'Payment confirmed via PhonePe Gateway',
        });
      }

      return ResponseHandler.success(res, {
        status: found ? found.status : 'PENDING',
        gatewayCode: gatewayStatus.code || 'PENDING',
        message: 'Payment is being processed by NPCI/PhonePe',
      });
    } catch (err) {
      logger.error(`Check status error: ${err.message}`);
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * 4. Sandbox Simulator Quick Confirmation (Test Sandbox Mode Only)
   * POST /api/v1/payments/phonepe/simulate-success
   */
  static async simulateSuccess(req, res) {
    try {
      const { merchantTransactionId, bankUtr } = req.body;

      if (!merchantTransactionId) {
        return ResponseHandler.error(res, 'merchantTransactionId is required', 400);
      }

      const result = await PhonePeService.completePayment({
        merchantTransactionId,
        bankUtr: bankUtr || `MOCK-UTR-${Date.now()}`,
        providerReferenceId: `PP-SIM-${Date.now()}`,
      });

      return ResponseHandler.success(
        res,
        result,
        'Sandbox payment simulated & fulfilled successfully in Test Mode!'
      );
    } catch (err) {
      logger.error(`Simulate success error: ${err.message}`);
      return ResponseHandler.error(res, err.message, 500);
    }
  }
}

module.exports = PhonePeController;
