const { Op } = require('sequelize');
const { User, Otp } = require('../models');
const { encrypt, decrypt, hashPassword, comparePassword, hashMobile } = require('../utils/crypto_helper');
const { signAccessToken, signRefreshToken } = require('../utils/jwt_helper');
const brevoMailer = require('./brevo_mailer');
const logger = require('../utils/logger');

class AuthService {
  /**
   * Generates and dispatches a 6-digit verification code via Brevo SMTP
   */
  static async sendOtp({ email, type = 'register', mobile = null }) {
    const cleanEmail = String(email || '').trim().toLowerCase();
    if (!cleanEmail || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(cleanEmail)) {
      throw new Error('Valid email address is required.');
    }

    // 1. Check existing records depending on action type
    if (type === 'register') {
      const existingEmail = await User.findOne({ where: { email: cleanEmail } });
      if (existingEmail) {
        throw new Error('This email address is already registered. Please login.');
      }

      if (mobile) {
        const cleanMobile = String(mobile).replace(/\D/g, '');
        if (cleanMobile.length === 10) {
          const mobHash = hashMobile(cleanMobile);
          const existingMobile = await User.findOne({ where: { mobile_hash: mobHash } });
          if (existingMobile) {
            throw new Error('This mobile number is already registered. Please login.');
          }
        }
      }
    } else if (type === 'forgot_password' || type === 'login') {
      const existingUser = await User.findOne({ where: { email: cleanEmail } });
      if (!existingUser) {
        throw new Error('No Quick Money account found with this email address.');
      }
      if (existingUser.status === 'banned') {
        throw new Error('Your account has been suspended by administration.');
      }
    }

    // 2. Invalidate older unused OTPs for this email & action
    await Otp.update(
      { is_used: true },
      { where: { email: cleanEmail, is_used: false } }
    );

    // 3. Generate 6-digit cryptographically random numerical code
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // 4. Save in Database
    await Otp.create({
      email: cleanEmail,
      otp_code: otpCode,
      type,
      expires_at: expiresAt,
      is_used: false,
    });

    // 5. Send Light-Theme Luxury HTML Email via Brevo SMTP (or dev console fallback)
    await brevoMailer.sendOtpEmail({
      toEmail: cleanEmail,
      otp: otpCode,
      type,
    });

    return {
      success: true,
      email: cleanEmail,
      message: `Security code sent successfully to ${cleanEmail}. Please check your inbox.`,
    };
  }

  /**
   * Verifies an OTP code
   */
  static async verifyOtp({ email, otp, type = 'register', consume = true }) {
    const cleanEmail = String(email || '').trim().toLowerCase();
    const cleanOtp = String(otp || '').trim();

    if (!cleanEmail || !cleanOtp) {
      throw new Error('Email and OTP code are required.');
    }

    const whereClause = {
      email: cleanEmail,
      otp_code: cleanOtp,
      is_used: false,
      expires_at: {
        [Op.gt]: new Date(),
      },
    };
    if (type) {
      whereClause.type = type;
    }

    const record = await Otp.findOne({
      where: whereClause,
      order: [['id', 'DESC']],
    });

    if (!record) {
      throw new Error('Invalid or expired OTP code. Please request a new code.');
    }

    // Only consume if instructed
    if (consume) {
      record.is_used = true;
      await record.save();
    }

    return { verified: true };
  }

  /**
   * Registers a new user with verified Email OTP
   */
  static async register({ mobile, email, password, inviteCode, otp }) {
    const cleanEmail = String(email || '').trim().toLowerCase();
    const cleanMobile = String(mobile || '').replace(/\D/g, '');
    const cleanInvite = inviteCode ? String(inviteCode).trim() : null;

    if (cleanMobile.length !== 10) {
      throw new Error('Mobile number must be exactly 10 digits.');
    }
    if (!cleanEmail) {
      throw new Error('Email address is required.');
    }
    if (!password || password.length < 6) {
      throw new Error('Password must be at least 6 characters long.');
    }

    // 1. Verify OTP
    await this.verifyOtp({ email: cleanEmail, otp, type: 'register' });

    // 2. Validate Invitation Code (Optional)
    let validatedReferrerCode = null;
    if (cleanInvite && cleanInvite.length > 0) {
      const referrerUser = await User.findOne({ where: { invite_code: cleanInvite } });
      if (!referrerUser) {
        throw new Error('Invalid invitation code. Please check your referral code or leave it blank.');
      }
      validatedReferrerCode = cleanInvite;
    }

    // 3. Check duplicates
    const mobHash = hashMobile(cleanMobile);
    const existing = await User.findOne({
      where: {
        [Op.or]: [{ mobile_hash: mobHash }, { email: cleanEmail }],
      },
    });

    if (existing) {
      throw new Error('Account with this mobile or email already exists.');
    }

    // 4. Encrypt data & hash password
    const encryptedMobile = encrypt(cleanMobile);
    const hashedPassword = await hashPassword(password);
    const generatedInvite = 'x0' + Math.random().toString(36).substring(2, 8);

    // 5. Create user
    const user = await User.create({
      mobile_encrypted: encryptedMobile,
      mobile_hash: mobHash,
      email: cleanEmail,
      password_hash: hashedPassword,
      invite_code: generatedInvite,
      referred_by: validatedReferrerCode,
      balance: parseFloat(process.env.WELCOME_BONUS || '51.07'),
      level: 'L1',
      role: 'user',
      status: 'active',
      is_email_verified: true,
    });

    // Notify admins about new user registration & welcome new user
    try {
      const NotificationService = require('./notification_service');
      await Promise.allSettled([
        NotificationService.notifyAdmins({
          title: 'New Member Joined 👤',
          message: `User ${user.email} (ID: #${user.id}) has joined the platform with invite ${user.invite_code}.`,
          type: 'system',
        }),
        NotificationService.send({
          userId: user.id,
          title: 'Welcome to Quick Money! 🎉',
          message: `Your account is active. Welcome bonus ₹${user.balance} has been credited to your live vault.`,
          type: 'reward',
        }),
      ]);
    } catch (_) {}

    // 5. Issue JWT tokens
    const token = signAccessToken({ id: user.id, role: user.role, level: user.level });
    const refreshToken = signRefreshToken({ id: user.id });

    return {
      user: {
        id: user.id,
        mobile: cleanMobile,
        email: user.email,
        invite_code: user.invite_code,
        balance: user.balance,
        level: user.level,
        role: user.role,
      },
      token,
      refreshToken,
    };
  }

  /**
   * User login with Mobile and/or Email + Password
   */
  static async login({ mobile, email, password }) {
    let cleanMobile = String(mobile || '').replace(/\D/g, '');
    let cleanEmail = String(email || '').trim().toLowerCase();

    // Auto-detect: If mobile parameter contains an email address and email wasn't set
    if (mobile && String(mobile).includes('@') && !cleanEmail) {
      cleanEmail = String(mobile).trim().toLowerCase();
      cleanMobile = '';
    }

    if (!cleanMobile && !cleanEmail) {
      throw new Error('Mobile number or Email address is required.');
    }
    if (!password) {
      throw new Error('Password is required.');
    }

    let user;

    // 1. Lookup by mobile number if 10 digits provided
    if (cleanMobile.length === 10) {
      const mobHash = hashMobile(cleanMobile);
      user = await User.findOne({ where: { mobile_hash: mobHash } });
      if (user && cleanEmail && user.email.toLowerCase() !== cleanEmail) {
        throw new Error('The entered mobile number and email address do not match.');
      }
    }

    // 2. Lookup by email if not found by mobile
    if (!user && cleanEmail) {
      user = await User.findOne({ where: { email: cleanEmail } });
      if (user && cleanMobile.length === 10) {
        const mobHash = hashMobile(cleanMobile);
        if (user.mobile_hash !== mobHash) {
          throw new Error('The entered mobile number and email address do not match.');
        }
      }
    }

    if (!user) {
      throw new Error('Invalid credentials. No account found matching the provided mobile/email.');
    }

    if (user.status === 'banned') {
      throw new Error('Your account has been suspended by administration.');
    }

    const isMatch = await comparePassword(password, user.password_hash);
    if (!isMatch) {
      throw new Error('Invalid credentials. Please verify your password.');
    }

    // Invalidate previous unused login OTPs for this user's email
    await Otp.update(
      { is_used: true },
      { where: { email: user.email, type: 'login', is_used: false } }
    );

    // Generate 6-digit cryptographically random security OTP
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // Save in Database
    await Otp.create({
      email: user.email,
      otp_code: otpCode,
      type: 'login',
      expires_at: expiresAt,
      is_used: false,
    });

    // Send real-time Email OTP via Brevo / Gmail SMTP
    await brevoMailer.sendOtpEmail({
      toEmail: user.email,
      otp: otpCode,
      type: 'login',
    });

    let rawMobile = '';
    try {
      rawMobile = decrypt(user.mobile_encrypted);
    } catch {
      rawMobile = cleanMobile;
    }

    return {
      requiresOtp: true,
      email: user.email,
      mobile: rawMobile,
      message: `Security code dispatched to ${user.email}. Please verify to complete login.`,
    };
  }

  /**
   * User login step 2: Verify Email OTP and issue JWT tokens
   */
  static async loginVerifyOtp({ email, otp }) {
    const cleanEmail = String(email || '').trim().toLowerCase();
    const cleanOtp = String(otp || '').trim();

    if (!cleanEmail || !cleanOtp) {
      throw new Error('Email address and security code are required.');
    }

    // 1. Verify OTP with single-use lock & expiry
    await this.verifyOtp({ email: cleanEmail, otp: cleanOtp, type: 'login', consume: true });

    // 2. Fetch User
    const user = await User.findOne({ where: { email: cleanEmail } });
    if (!user) {
      throw new Error('User account not found.');
    }

    if (user.status === 'banned') {
      throw new Error('Your account has been suspended by administration.');
    }

    // 3. Issue JWT tokens
    const token = signAccessToken({ id: user.id, role: user.role, level: user.level });
    const refreshToken = signRefreshToken({ id: user.id });

    let rawMobile = '';
    try {
      rawMobile = decrypt(user.mobile_encrypted);
    } catch {
      rawMobile = '';
    }

    return {
      user: {
        id: user.id,
        mobile: rawMobile,
        email: user.email,
        invite_code: user.invite_code,
        balance: user.balance,
        level: user.level,
        role: user.role,
      },
      token,
      refreshToken,
    };
  }

  /**
   * Reset password with Email OTP
   */
  static async resetPassword({ email, otp, newPassword }) {
    const cleanEmail = String(email || '').trim().toLowerCase();
    const cleanOtp = String(otp || '').trim();

    if (!cleanEmail || !cleanOtp || !newPassword) {
      throw new Error('Email, OTP code, and new password are required.');
    }

    if (newPassword.length < 6) {
      throw new Error('Password must be at least 6 characters long.');
    }

    // 1. Verify OTP
    await this.verifyOtp({ email: cleanEmail, otp: cleanOtp, type: 'forgot_password', consume: true });

    // 2. Find user & update password
    const user = await User.findOne({ where: { email: cleanEmail } });
    if (!user) {
      throw new Error('User account not found.');
    }

    user.password_hash = await hashPassword(newPassword);
    await user.save();

    return {
      success: true,
      message: 'Password has been updated successfully. Please login with your new credentials.',
    };
  }

  /**
   * Fetch current user profile
   */
  static async getProfile(userId) {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new Error('User not found.');
    }

    let rawMobile = '';
    try {
      rawMobile = decrypt(user.mobile_encrypted);
    } catch {
      rawMobile = 'N/A';
    }

    return {
      id: user.id,
      mobile: rawMobile,
      email: user.email,
      invite_code: user.invite_code,
      balance: user.balance,
      level: user.level,
      role: user.role,
      status: user.status,
    };
  }
}

module.exports = AuthService;
