const express = require('express');
const OrderController = require('../controllers/order_controller');
const authMiddleware = require('../middleware/auth_middleware');

const router = express.Router();
router.use(authMiddleware);

router.get('/', OrderController.listOrders);
router.post('/submit-utr', OrderController.submitUtrDeposit);
router.post('/:orderId/receive', OrderController.receiveOrder);

module.exports = router;

