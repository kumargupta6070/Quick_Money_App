const express = require('express');
const TransactionController = require('../controllers/transaction_controller');
const authMiddleware = require('../middleware/auth_middleware');

const router = express.Router();
router.use(authMiddleware);

router.get('/', TransactionController.getHistory);
router.post('/request-payout', TransactionController.requestPayout);

module.exports = router;

