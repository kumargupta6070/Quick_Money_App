const express = require('express');
const router = express.Router();
const { SystemSetting } = require('../models');
const ResponseHandler = require('../utils/response_handler');
const brevoMailer = require('../services/brevo_mailer');

// Default fallback release metadata
const DEFAULT_RELEASE = {
  version: '1.0.0',
  version_code: 1,
  download_url: 'https://quick-moneey.netlify.app/quick-money.apk',
  file_size: '65.9 MB',
  release_notes: 'Official Public Release with PhonePe Auto-Return, Real Email OTP & AES-256 Vault',
  is_active: true,
  sha256: 'f0ba78708848f62771f9fe367b735c2451a6932bc0734b4c809667134124eaac',
  updated_at: new Date().toISOString(),
};

/**
 * @swagger
 * /api/v1/system/app-release:
 *   get:
 *     summary: Public API to fetch current active Android APK release for the website
 *     tags: [System]
 */
router.get('/app-release', async (req, res) => {
  try {
    const setting = await SystemSetting.findOne({ where: { key: 'app_apk_release' } });
    if (!setting) {
      return ResponseHandler.success(res, DEFAULT_RELEASE, 'Default app release metadata');
    }
    const parsed = JSON.parse(setting.value);
    if (!parsed.download_url || parsed.download_url.includes('github.com/kumargupta6070/Quick_Money_App/releases')) {
      parsed.download_url = 'https://quick-moneey.netlify.app/quick-money.apk';
    }
    return ResponseHandler.success(res, parsed, 'Latest APK release metadata');
  } catch (error) {
    return ResponseHandler.success(res, DEFAULT_RELEASE, 'Fallback release metadata');
  }
});

/**
 * Health & diagnostic check for live email transmission
 */
router.get('/mail-diagnostic', async (req, res) => {
  try {
    const isReady = Boolean(brevoMailer.transporter);
    const { toEmail } = req.query;
    let sendResult = null;
    if (toEmail) {
      sendResult = await brevoMailer.sendOtpEmail({
        toEmail: String(toEmail).trim().toLowerCase(),
        otp: '998877',
        type: 'test',
      });
    }
    return ResponseHandler.success(res, {
      service: 'gmail',
      user: process.env.EMAIL_USER || 'quick.moneey.in@gmail.com',
      transporterReady: isReady,
      sendResult,
    }, 'Mail diagnostic check completed');
  } catch (error) {
    return ResponseHandler.error(res, error.message, 500);
  }
});

module.exports = router;
