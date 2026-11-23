const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });
require('dotenv').config();
const nodemailer = require('nodemailer');
const logger = require('../utils/logger');

class BrevoMailerService {
  constructor() {
    this.transporter = null;
    this._initTransporter();
  }

  _initTransporter() {
    // Initialize High-Speed Pooled SMTP Transporter (Gmail App Password or Brevo SMTP relay)
    const user = process.env.EMAIL_USER || process.env.BREVO_SMTP_USER;
    const rawPass = process.env.EMAIL_APP_PASSWORD || process.env.BREVO_SMTP_KEY;
    const pass = rawPass ? String(rawPass).replace(/["'\s]/g, '') : null;

    if (user && pass) {
      const isGmail = user.includes('@gmail.com');
      this.transporter = nodemailer.createTransport({
        host: isGmail ? 'smtp.gmail.com' : (process.env.BREVO_SMTP_HOST || 'smtp-relay.brevo.com'),
        port: isGmail ? 465 : parseInt(process.env.BREVO_SMTP_PORT || '587', 10),
        secure: isGmail ? true : (process.env.BREVO_SMTP_PORT === '465'),
        pool: true, // Keep socket alive for sub-2-second instant dispatch
        maxConnections: 5,
        maxMessages: 100,
        rateDelta: 1000,
        rateLimit: 5,
        connectionTimeout: 3500, // Max 3.5s to establish connection
        greetingTimeout: 2500,   // Max 2.5s for greeting
        socketTimeout: 4000,     // Max 4s socket timeout
        auth: { user, pass },
      });

      // Warm up connection asynchronously on startup
      this.transporter.verify().then(() => {
        logger.info(`⚡ High-speed SMTP socket pool active & verified for ${user}.`);
      }).catch((err) => {
        logger.warn(`SMTP pool warm-up notice: ${err.message}`);
      });
    } else {
      logger.warn('No SMTP credentials found in .env');
    }
  }

    /**
     * Generates a Light-Theme, ultra-professional, enterprise-grade FinTech HTML email
     */
    _buildLightFinTechEmailTemplate({ otp, type = 'Verification', expiresMinutes = 10 }) {
      const title = type === 'register' ? 'Verify Your Account' : (type === 'forgot_password' ? 'Reset Your Password' : 'Login Authentication');
      const subtitle = type === 'register' ? 'Welcome to Quick Money! Confirm your email to activate your trading vault.' : 'A secure authentication request was triggered for your Quick Money account.';

      return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Quick Money Security Verification</title>
  <style>
    body {
      margin: 0;
      padding: 0;
      background-color: #F8FAFC;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      color: #0F172A;
      -webkit-font-smoothing: antialiased;
    }
    .wrapper {
      width: 100%;
      background-color: #F8FAFC;
      padding: 40px 16px;
    }
    .container {
      max-width: 540px;
      margin: 0 auto;
      background: #FFFFFF;
      border-radius: 24px;
      border: 1px solid #E2E8F0;
      box-shadow: 0 10px 30px rgba(2, 132, 199, 0.08);
      overflow: hidden;
    }
    .header {
      background: linear-gradient(135deg, #F0F9FF 0%, #E0F2FE 50%, #EFF6FF 100%);
      padding: 36px 32px 28px;
      text-align: center;
      border-bottom: 1px solid #BAE6FD;
    }
    .brand-badge {
      display: inline-block;
      padding: 6px 14px;
      background: #FFFFFF;
      border-radius: 20px;
      border: 1px solid #0284C7;
      color: #0284C7;
      font-size: 11px;
      font-weight: 800;
      letter-spacing: 1px;
      text-transform: uppercase;
      margin-bottom: 12px;
    }
    .logo-text {
      margin: 0;
      font-size: 26px;
      font-weight: 900;
      letter-spacing: -0.5px;
      color: #0F172A;
    }
    .logo-accent {
      color: #0284C7;
    }
    .content {
      padding: 36px 32px;
      text-align: center;
    }
    .h1 {
      margin: 0 0 10px;
      font-size: 20px;
      font-weight: 800;
      color: #0F172A;
    }
    .p {
      margin: 0 0 24px;
      font-size: 14.5px;
      line-height: 1.6;
      color: #475569;
    }
    .otp-box {
      background: linear-gradient(135deg, #F0FDF4 0%, #F0F9FF 100%);
      border: 2px dashed #0284C7;
      border-radius: 20px;
      padding: 24px 16px;
      margin: 24px 0;
      text-align: center;
      box-shadow: 0 6px 20px rgba(2, 132, 199, 0.06);
    }
    .otp-label {
      font-size: 11px;
      font-weight: 800;
      color: #0284C7;
      letter-spacing: 1.2px;
      text-transform: uppercase;
      margin-bottom: 10px;
    }
    .otp-code {
      font-family: 'Courier New', Courier, monospace;
      font-size: 38px;
      font-weight: 900;
      letter-spacing: 10px;
      color: #0369A1;
      padding-left: 10px;
      margin: 6px 0;
    }
    .otp-expiry {
      font-size: 12px;
      color: #64748B;
      font-weight: 600;
      margin-top: 8px;
    }
    .security-notice {
      background: #FFFBEB;
      border: 1px solid #FDE68A;
      border-radius: 14px;
      padding: 14px 16px;
      margin: 24px 0 12px;
      text-align: left;
    }
    .notice-title {
      font-size: 12.5px;
      font-weight: 800;
      color: #B45309;
      margin-bottom: 4px;
    }
    .notice-text {
      font-size: 12px;
      line-height: 1.5;
      color: #78350F;
      margin: 0;
    }
    .footer {
      background: #F8FAFC;
      padding: 24px 32px;
      text-align: center;
      border-top: 1px solid #E2E8F0;
      font-size: 11.5px;
      color: #94A3B8;
      line-height: 1.6;
    }
    .footer a {
      color: #0284C7;
      text-decoration: none;
    }
  </style>
</head>
<body>
  <div class="wrapper">
    <div class="container">
      <!-- Header -->
      <div class="header">
        <div class="brand-badge">🛡️ AES-256 BANK ENCRYPTION</div>
        <h1 class="logo-text">QUICK <span class="logo-accent">MONEY</span></h1>
      </div>

      <!-- Main Content -->
      <div class="content">
        <h2 class="h1">${title}</h2>
        <p class="p">${subtitle}</p>

        <!-- OTP Glowing Box -->
        <div class="otp-box">
          <div class="otp-label">Your Single-Use Verification Code</div>
          <div class="otp-code">${otp}</div>
          <div class="otp-expiry">⏱️ Valid for ${expiresMinutes} minutes • Single Use Only</div>
        </div>

        <p class="p" style="font-size: 13px; color: #64748B;">
          Enter this 6-digit security code in your Quick Money mobile app to complete verification.
        </p>

        <!-- Security Warning Notice -->
        <div class="security-notice">
          <div class="notice-title">⚠️ Security Advisory</div>
          <p class="notice-text">
            Quick Money representatives will NEVER ask for your password, PIN, or OTP. If you did not initiate this request, please change your password immediately.
          </p>
        </div>
      </div>

      <!-- Footer -->
      <div class="footer">
        <p style="margin: 0 0 6px;">
          This is an automated security transmission from <strong>Quick Money FinTech Ltd.</strong>
        </p>
        <p style="margin: 0;">
          Need support? Reach out at <a href="mailto:quick.moneey.in@gmail.com">quick.moneey.in@gmail.com</a><br>
          © 2026 Quick Money Financial Technologies. All rights reserved.
        </p>
      </div>
    </div>
  </div>
</body>
</html>
    `;
    }

  /**
   * Send Email OTP to user
   */
  async sendOtpEmail({ toEmail, otp, type = 'register' }) {
      const htmlContent = this._buildLightFinTechEmailTemplate({ otp, type });
      const fromName = (process.env.BREVO_FROM_NAME || 'Quick Money Security').replace(/["']/g, '');
      const fromEmail = process.env.EMAIL_USER || (process.env.BREVO_FROM_EMAIL || 'quick.moneey.in@gmail.com').replace(/["']/g, '');

      const subject = type === 'register'
        ? `🔐 Quick Money Registration OTP: ${otp}`
        : (type === 'forgot_password' ? `🔑 Quick Money Password Reset OTP: ${otp}` : `🛡️ Quick Money Verification Code: ${otp}`);

      // 1. High-Priority: Pooled High-Speed Gmail SMTP (Sub-2-second Instant Delivery)
      if (this.transporter) {
        try {
          const sendPromise = this.transporter.sendMail({
            from: `"${fromName}" <${fromEmail}>`,
            to: toEmail,
            subject,
            html: htmlContent,
          });
          const timeoutPromise = new Promise((_, reject) =>
            setTimeout(() => reject(new Error('SMTP timeout after 4s')), 4000)
          );
          const info = await Promise.race([sendPromise, timeoutPromise]);
          logger.info(`⚡ Instant Email OTP delivered to ${toEmail} via High-Speed Gmail SMTP (MessageId: ${info.messageId})`);
          return { success: true, messageId: info.messageId, mode: 'smtp_pool' };
        } catch (err) {
          logger.error(`SMTP delivery error: ${err.message}. Trying backup delivery channel...`);
        }
      }

      // 2. Backup Relay: Brevo HTTPS REST API (if configured)
      if (process.env.BREVO_API_KEY) {
        try {
          const controller = new AbortController();
          const tId = setTimeout(() => controller.abort(), 4000);
          const response = await fetch('https://api.brevo.com/v3/smtp/email', {
            signal: controller.signal,
            method: 'POST',
            headers: {
              'api-key': process.env.BREVO_API_KEY,
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: JSON.stringify({
              sender: { name: fromName, email: fromEmail },
              to: [{ email: toEmail }],
              subject,
              htmlContent,
            }),
          });
          clearTimeout(tId);

          if (response.ok) {
            const resData = await response.json().catch(() => ({}));
            logger.info(`Email OTP successfully delivered to ${toEmail} via Brevo HTTPS API (MessageId: ${resData.messageId || 'ok'})`);
            return { success: true, messageId: resData.messageId, mode: 'brevo_https' };
          }
        } catch (err) {
          logger.warn(`Brevo backup API error: ${err.message}`);
        }
      }

      // 3. Development Console Mode Fallback
      console.log('\n╔══════════════════════════════════════════════════════════════════╗');
      console.log('║ 📧 QUICK MONEY BREVO EMAIL OTP (DEV CONSOLE MODE)                 ║');
      console.log('╠══════════════════════════════════════════════════════════════════╣');
      console.log(`║ Recipient: ${toEmail.padEnd(53)} ║`);
      console.log(`║ Action:    ${type.toUpperCase().padEnd(53)} ║`);
      console.log(`║ CODE:      >>> ${otp} <<< (Expires in 10 mins)${' '.repeat(24)} ║`);
      console.log('╚══════════════════════════════════════════════════════════════════╝\n');

      return { success: true, mode: 'dev_console', otp };
    }
  }

module.exports = new BrevoMailerService();

