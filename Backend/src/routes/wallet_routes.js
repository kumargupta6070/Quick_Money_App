const express = require('express');
const { body } = require('express-validator');
const WalletController = require('../controllers/wallet_controller');
const authMiddleware = require('../middleware/auth_middleware');
const validate = require('../middleware/validator');

const router = express.Router();
router.use(authMiddleware);

router.get('/', WalletController.getWallet);
router.post(
  '/bind',
  [body('upi_id').notEmpty().withMessage('UPI ID is required')],
  validate,
  WalletController.bindWallet
);
router.post('/unbind', WalletController.unbindWallet);
router.delete('/', WalletController.unbindWallet);

module.exports = router;

