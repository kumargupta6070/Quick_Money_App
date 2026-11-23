const express = require('express');
const PhonePeController = require('../controllers/phonepe_controller');
const authMiddleware = require('../middleware/auth_middleware');

const router = express.Router();

// 1. Initiate PhonePe Buy RP payment (Native UPI Intent / Web Checkout)
router.post('/phonepe/initiate', authMiddleware, PhonePeController.initiatePayment);

// 2. PhonePe Webhook Server-to-Server Callback (Direct from PhonePe servers)
router.post('/phonepe/callback', PhonePeController.handleWebhook);

// 3. Check Payment Status
router.get('/phonepe/status/:txnId', authMiddleware, PhonePeController.checkStatus);

// 4. Sandbox Simulator Fast-Track (Test Mode only)
router.post('/phonepe/simulate-success', authMiddleware, PhonePeController.simulateSuccess);

module.exports = router;
