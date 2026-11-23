const AuthService = require('../services/auth_service');
const ResponseHandler = require('../utils/response_handler');

class AuthController {
  static async sendOtp(req, res) {
    try {
      const { email, type, mobile } = req.body;
      const data = await AuthService.sendOtp({ email, type, mobile });
      return ResponseHandler.success(res, data, data.message || 'OTP sent successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 400);
    }
  }

  static async verifyOtp(req, res) {
    try {
      const { email, otp, type, consume } = req.body;
      const shouldConsume = type === 'forgot_password' ? false : (consume !== false);
      const data = await AuthService.verifyOtp({ email, otp, type, consume: shouldConsume });
      return ResponseHandler.success(res, data, 'OTP verified successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 400);
    }
  }

  static async register(req, res) {
    try {
      const { mobile, email, password, inviteCode, otp } = req.body;
      const data = await AuthService.register({ mobile, email, password, inviteCode, otp });
      return ResponseHandler.success(res, data, 'Account registered successfully with welcome bonus!', 201);
    } catch (err) {
      return ResponseHandler.error(res, err.message, 400);
    }
  }

  static async login(req, res) {
    try {
      const { mobile, email, password } = req.body;
      const data = await AuthService.login({ mobile, email, password });
      return ResponseHandler.success(res, data, data.message || 'Credentials verified. Please enter the OTP sent to your email.');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 400);
    }
  }

  static async loginVerifyOtp(req, res) {
    try {
      const { email, otp } = req.body;
      const data = await AuthService.loginVerifyOtp({ email, otp });
      return ResponseHandler.success(res, data, 'Login authenticated successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 400);
    }
  }

  static async resetPassword(req, res) {
    try {
      const { email, otp, newPassword } = req.body;
      const data = await AuthService.resetPassword({ email, otp, newPassword });
      return ResponseHandler.success(res, data, data.message);
    } catch (err) {
      return ResponseHandler.error(res, err.message, 400);
    }
  }

  static async me(req, res) {
    try {
      const userId = req.user.id;
      const data = await AuthService.getProfile(userId);
      return ResponseHandler.success(res, data, 'User profile fetched successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 400);
    }
  }

  static async logout(req, res) {
    try {
      return ResponseHandler.success(res, null, 'Logged out successfully. Vault session closed.');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }
}

module.exports = AuthController;
