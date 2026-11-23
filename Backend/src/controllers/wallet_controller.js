const { Wallet } = require('../models');
const { encrypt, decrypt } = require('../utils/crypto_helper');
const ResponseHandler = require('../utils/response_handler');

class WalletController {
  static async getWallet(req, res) {
    try {
      const wallet = await Wallet.findOne({ where: { user_id: req.user.id } });
      if (!wallet) {
        return ResponseHandler.success(res, null, 'No wallet bound');
      }
      return ResponseHandler.success(res, {
        id: wallet.id,
        payment_app: wallet.payment_app,
        upi_id: decrypt(wallet.upi_id_encrypted),
        account_holder_name: decrypt(wallet.account_name_encrypted),
        status: wallet.status,
        status_detail: wallet.status_detail,
        bound_at: wallet.created_at,
      });
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async unbindWallet(req, res) {
    try {
      const wallet = await Wallet.findOne({ where: { user_id: req.user.id } });
      if (!wallet) {
        return ResponseHandler.error(res, 'No wallet bound to disconnect', 404);
      }
      await wallet.destroy();
      return ResponseHandler.success(res, null, 'PhonePe wallet unbound successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async bindWallet(req, res) {
    try {
      const { payment_app, upi_id, account_holder_name } = req.body;
      const encryptedUpi = encrypt(upi_id);
      const encryptedName = encrypt(account_holder_name || '');

      let wallet = await Wallet.findOne({ where: { user_id: req.user.id } });
      if (wallet) {
        await wallet.update({
          payment_app: payment_app || 'phonepe',
          upi_id_encrypted: encryptedUpi,
          account_name_encrypted: encryptedName,
          status: 'active',
          status_detail: 'Verified',
        });
      } else {
        wallet = await Wallet.create({
          user_id: req.user.id,
          payment_app: payment_app || 'phonepe',
          upi_id_encrypted: encryptedUpi,
          account_name_encrypted: encryptedName,
          status: 'active',
          status_detail: 'Verified',
        });
      }

      return ResponseHandler.success(res, {
        id: wallet.id,
        payment_app: wallet.payment_app,
        upi_id,
        status: 'active',
      }, 'Wallet bound successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }
}

module.exports = WalletController;

