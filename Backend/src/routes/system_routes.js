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

    const detectedKeys = {
      hasBrevoApiKey: Boolean(process.env.BREVO_API_KEY),
      brevoKeyPrefix: process.env.BREVO_API_KEY ? process.env.BREVO_API_KEY.substring(0, 8) + '...' : null,
      brevoKeyLength: process.env.BREVO_API_KEY ? process.env.BREVO_API_KEY.trim().length : 0,
      hasBrevoKey: Boolean(process.env.BREVO_KEY),
      hasBrevoSmtpKey: Boolean(process.env.BREVO_SMTP_KEY),
      hasBrevoSmtpUser: Boolean(process.env.BREVO_SMTP_USER),
      hasBrevoFromEmail: Boolean(process.env.BREVO_FROM_EMAIL),
      hasResendApiKey: Boolean(process.env.RESEND_API_KEY),
      hasEmailUser: Boolean(process.env.EMAIL_USER),
      hasEmailPass: Boolean(process.env.EMAIL_APP_PASSWORD),
    };

    let brevoDirectTest = null;
    const bKey = (process.env.BREVO_API_KEY || process.env.BREVO_KEY || process.env.BREVO_SMTP_KEY)?.replace(/["'\s]/g, '');
    if (toEmail && bKey) {
      const fromEmail = (process.env.BREVO_FROM_EMAIL || process.env.EMAIL_USER || 'quick.moneey.in@gmail.com').replace(/["'\s]/g, '');
      try {
        const r = await fetch('https://api.brevo.com/v3/smtp/email', {
          method: 'POST',
          headers: {
            'api-key': bKey,
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: JSON.stringify({
            sender: { name: 'Quick Money Security', email: fromEmail },
            to: [{ email: toEmail }],
            subject: 'Quick Money Brevo Direct Test',
            htmlContent: '<p>Test</p>',
          }),
        });
        const d = await r.json().catch(() => ({}));
        brevoDirectTest = { status: r.status, ok: r.ok, fromEmail, data: d };
      } catch (e) {
        brevoDirectTest = { error: e.message };
      }
    }

    let brevoSmtpTest = null;
    if (toEmail && bKey) {
      try {
        const nodemailer = require('nodemailer');
        const sUser = process.env.BREVO_SMTP_USER || process.env.BREVO_FROM_EMAIL || process.env.EMAIL_USER;
        const testTransporter = nodemailer.createTransport({
          host: 'smtp-relay.brevo.com',
          port: 2525,
          secure: false,
          auth: {
            user: sUser,
            pass: bKey,
          },
          connectionTimeout: 5000,
        });
        const sInfo = await testTransporter.sendMail({
          from: '"Quick Money" <' + sUser + '>',
          to: toEmail,
          subject: 'Brevo SMTP 2525 Test',
          text: 'Test',
        });
        brevoSmtpTest = { success: true, messageId: sInfo.messageId };
      } catch (e) {
        brevoSmtpTest = { error: e.message, code: e.code };
      }
    }

    if (toEmail) {
      sendResult = await brevoMailer.sendOtpEmail({
        toEmail: String(toEmail).trim().toLowerCase(),
        otp: '782914',
        type: 'register',
      });
    }

    return ResponseHandler.success(res, {
      detectedKeys,
      transporterReady: isReady,
      brevoDirectTest,
      brevoSmtpTest,
      sendResult,
    }, 'Mail diagnostic check completed');
  } catch (error) {
    return ResponseHandler.error(res, error.message, 500);
  }
});

module.exports = router;
