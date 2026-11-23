# ⚡ Quick Money — Live Backend & Brevo Email OTP Authentication Master Plan

> **Objective:** Transition Quick Money from a mock UI prototype to a live production platform with Node.js, Express, MySQL, Brevo (Sendinblue) SMTP Email OTP verification, and an in-app Mobile Admin Panel.

---

## 💡 Strategic Decisions & Cost Optimization

1. **Email OTP via Brevo (Sendinblue) SMTP instead of Mobile SMS:**
   - **Cost:** ₹0.00 (Brevo provides **300 free emails/day** forever on free tier).
   - **Speed & Reliability:** Instant delivery (2-5 seconds), no telecom DLT registration delays, no DND (Do Not Disturb) blocking.
   - **Flow:** User enters their **10-Digit Mobile Number** as their primary account handle + **Email Address** for OTP verification.
   - **Security:** Account verification & password recovery OTPs arrive directly in the user's inbox with a branded Quick Money luxury HTML email.

2. **Mobile-First Admin Panel (No Web Required):**
   - **Role-Based Access Control (RBAC):** Database me `role: 'user'` aur `role: 'admin'`.
   - Jab normal user login karega -> Normal Customer screens open hongi.
   - Jab Client/Admin login karega -> Mobile app me **"Admin Operations Center"** khulega jahan se wo deposits verify, withdrawals settle, users freeze, aur UPI change kar sakega!

---

## 🏛️ System Architecture & Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                   QUICK MONEY FLUTTER APP                   │
│  [Mobile No + Email + Password] ──► [6-Digit Email OTP Box] │
└──────────────────────────────┬──────────────────────────────┘
                               │ HTTPS / REST (JSON)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                 NODE.JS + EXPRESS BACKEND                   │
│  • Rate Limiting (Anti-Spam) • AES-256 Data Encryption      │
│  • Brevo SMTP Mailer Service • JWT Token Generation         │
└───────────────────┬─────────────────────┬───────────────────┘
                    │                     │
                    ▼                     ▼
     ┌──────────────────────┐    ┌─────────────────────┐
     │     MYSQL DATABASE   │    │  BREVO (SMTP RELAY) │
     │  • users (role, bal) │    │  • Send OTP Email   │
     │  • otps (code, exp)  │    │  • 300 free/day     │
     └──────────────────────┘    └─────────────────────┘
```

---

## 📋 Database Schema Updates

### 1. `users` Table (Enhanced)
| Column | Type | Attributes | Description |
| :--- | :--- | :--- | :--- |
| `id` | INT | PK, Auto Increment | Unique User ID |
| `mobile_encrypted` | VARCHAR(255) | Unique, Not Null | AES-256 encrypted phone number |
| `mobile_hash` | VARCHAR(64) | Indexed, Not Null | SHA-256 hash for fast indexing |
| `email` | VARCHAR(191) | Unique, Not Null | Verified user email |
| `password_hash` | VARCHAR(255) | Not Null | Bcrypt salted hash (10 rounds) |
| `invite_code` | VARCHAR(16) | Unique, Not Null | Unique referral code (e.g. `x0rZx2y0`) |
| `referred_by` | VARCHAR(16) | Nullable | Referrer's invite code |
| `role` | ENUM | `'user'`, `'admin'` | Default `'user'`. Admin accounts get control tools |
| `balance` | DECIMAL(12,2) | Default `51.07` | Current RP / Wallet balance |
| `level` | ENUM | `'L1'` to `'L7'` | Default `'L1'` |
| `status` | ENUM | `'active'`, `'suspended'`, `'banned'` | Account state |
| `is_email_verified` | BOOLEAN | Default `false` | Email verification flag |
| `created_at` / `updated_at` | DATETIME | Not Null | Timestamps |

### 2. `otps` Table (New)
| Column | Type | Attributes | Description |
| :--- | :--- | :--- | :--- |
| `id` | INT | PK, Auto Increment | Unique OTP ID |
| `email` | VARCHAR(191) | Indexed, Not Null | Recipient email |
| `otp_code` | VARCHAR(6) | Not Null | 6-Digit random numerical OTP |
| `type` | ENUM | `'register'`, `'login'`, `'forgot_password'` | Purpose of OTP |
| `expires_at` | DATETIME | Not Null | Valid for 10 minutes |
| `is_used` | BOOLEAN | Default `false` | Prevents OTP replay attacks |
| `created_at` | DATETIME | Not Null | Creation timestamp |

---

## 🔐 Complete Authentication API Specifications

### 1. Send OTP (`POST /api/v1/auth/send-otp`)
- **Body:** `{ "email": "user@gmail.com", "type": "register" | "forgot_password" | "login" }`
- **Logic:**
  1. If `type == 'register'`, check if email or mobile already registered.
  2. If `type == 'forgot_password'`, check if account exists.
  3. Generate 6-digit cryptographically secure OTP (e.g. `481920`).
  4. Save in `otps` table with `expires_at = NOW() + 10 MINUTES`.
  5. Send branded luxury HTML email via Brevo SMTP.
  6. Return `{ success: true, message: "OTP sent to your email successfully" }`.

### 2. Verify OTP (`POST /api/v1/auth/verify-otp`)
- **Body:** `{ "email": "user@gmail.com", "otp": "481920", "type": "register" }`
- **Logic:**
  1. Query active OTP where `email = email`, `otp_code = otp`, `is_used = false`, and `expires_at > NOW()`.
  2. If invalid or expired, return `400 Bad Request`.
  3. Mark `is_used = true`.
  4. Return verification ticket or success flag.

### 3. Register (`POST /api/v1/auth/register`)
- **Body:** `{ "mobile": "9835913180", "email": "user@gmail.com", "password": "...", "inviteCode": "...", "otp": "481920" }`
- **Logic:**
  1. Verify OTP first.
  2. Create user with bcrypt password and AES-256 encrypted mobile.
  3. Generate unique invite code.
  4. Credit welcome bonus (₹51.07).
  5. Issue JWT Access Token (24h) + Refresh Token (30d).
  6. Return user profile and tokens.

### 4. Login (`POST /api/v1/auth/login`)
- **Body:** `{ "mobile": "9835913180", "password": "..." }`
- **Logic:**
  1. Find user by mobile hash.
  2. Verify bcrypt password.
  3. If account suspended or banned, reject.
  4. Generate JWT tokens.
  5. Return user object including `role` (`'user'` or `'admin'`).

### 5. Forgot Password / Reset (`POST /api/v1/auth/reset-password`)
- **Body:** `{ "email": "user@gmail.com", "otp": "481920", "newPassword": "..." }`
- **Logic:**
  1. Verify OTP.
  2. Hash new password and update user record.
  3. Return success notification.

### 6. Get Current User (`GET /api/v1/auth/me`)
- **Header:** `Authorization: Bearer <JWT>`
- Returns real-time user balance, level, bound payment status, and role.

---

## 🏗️ Entire App Live Backend Modules (Beyond Auth)

| Module | Route Prefix | Key Functionality |
| :--- | :--- | :--- |
| **1. Auth & Users** | `/api/v1/auth` | Register with Email OTP, Login, Reset Password, User Profile |
| **2. Wallet & Payment Binding** | `/api/v1/wallets` | Bind PhonePe, GPay, Paytm UPI with AES-256 encryption |
| **3. Buy RP Marketplace** | `/api/v1/orders` | Packages (500 to 50,000), dynamic Admin QR Code, UTR submission |
| **4. Sell RP (Payouts)** | `/api/v1/payouts` | ₹100 auto-return guarantee, manual settlement, withdrawal history |
| **5. Daily Profit Engine** | `/api/v1/profits` | Nightly Cron Job calculating 2.5% yield + brokerage bonus |
| **6. 3-Tier Referral Engine** | `/api/v1/referrals` | 5% (L1), 3% (L2), 1% (L3) automated commission distribution |
| **7. Mobile Admin Controller** | `/api/v1/admin` | Approve/Reject UTR deposits, Settle payouts, Freeze users, Change QR |
| **8. Dynamic CMS & Alerts** | `/api/v1/banners` | Home carousel banners, pop-up announcements, support links |

