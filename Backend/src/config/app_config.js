const dotenv = require('dotenv');
dotenv.config();

module.exports = {
  port: process.env.PORT || 5000,
  env: process.env.NODE_ENV || 'development',
  profitReturnThreshold: parseFloat(process.env.PROFIT_RETURN_THRESHOLD || '100.00'),
  jwt: {
    secret: process.env.JWT_SECRET || 'quick_money_secret_jwt',
    expiresIn: process.env.JWT_EXPIRES_IN || '15m',
    refreshSecret: process.env.JWT_REFRESH_SECRET || 'quick_money_refresh_secret',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  },
  phonepe: {
    env: process.env.PHONEPE_ENV || 'SANDBOX',
    merchantId: process.env.PHONEPE_MERCHANT_ID || 'PGTESTPAYUAT',
    saltKey: process.env.PHONEPE_SALT_KEY || '099eb0cd-0252-4e28-a173-2e4edd08422f',
    saltIndex: process.env.PHONEPE_SALT_INDEX || '1',
    hostUrl: process.env.PHONEPE_HOST_URL || 'https://api-preprod.phonepe.com/apis/pg-sandbox',
    redirectUrl: process.env.PHONEPE_REDIRECT_URL || 'quickmoney://payment-return',
    callbackUrl: process.env.PHONEPE_CALLBACK_URL || 'http://localhost:5000/api/v1/payments/phonepe/callback',
  },
};
