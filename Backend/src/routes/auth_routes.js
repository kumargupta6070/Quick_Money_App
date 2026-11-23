const express = require('express');
const router = express.Router();
const AuthController = require('../controllers/auth_controller');
const authMiddleware = require('../middleware/auth_middleware');

// Public Auth Endpoints
router.post('/send-otp', AuthController.sendOtp);
router.post('/verify-otp', AuthController.verifyOtp);
router.post('/register', AuthController.register);
router.post('/login', AuthController.login);
router.post('/login-verify-otp', AuthController.loginVerifyOtp);
router.post('/reset-password', AuthController.resetPassword);

// Protected Auth Endpoints
router.get('/me', authMiddleware, AuthController.me);
router.post('/logout', authMiddleware, AuthController.logout);

module.exports = router;
