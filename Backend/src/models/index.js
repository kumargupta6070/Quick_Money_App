const sequelize = require('../config/database');
const User = require('./user_model');
const Wallet = require('./wallet_model');
const Order = require('./order_model');
const Transaction = require('./transaction_model');
const DailyProfit = require('./profit_model');
const Referral = require('./referral_model');
const Notification = require('./notification_model');
const Otp = require('./otp_model');
const SystemSetting = require('./system_setting_model');
const AuditLog = require('./audit_log_model');
const SupportTicket = require('./support_ticket_model');

// Associations
User.hasMany(Wallet, { foreignKey: 'user_id', as: 'wallets' });
Wallet.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

User.hasMany(Transaction, { foreignKey: 'user_id', as: 'transactions' });
Transaction.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

User.hasMany(Order, { foreignKey: 'seller_id', as: 'sold_orders' });
User.hasMany(Order, { foreignKey: 'buyer_id', as: 'bought_orders' });
Order.belongsTo(User, { foreignKey: 'buyer_id', as: 'buyer' });

User.hasMany(DailyProfit, { foreignKey: 'user_id', as: 'daily_profits' });
DailyProfit.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

User.hasMany(Referral, { foreignKey: 'referrer_id', as: 'referrals_made' });
Referral.belongsTo(User, { foreignKey: 'referrer_id', as: 'referrer' });

User.hasMany(Notification, { foreignKey: 'user_id', as: 'notifications' });
Notification.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

module.exports = {
  sequelize,
  User,
  Wallet,
  Order,
  Transaction,
  DailyProfit,
  Referral,
  Notification,
  Otp,
  SystemSetting,
  AuditLog,
  SupportTicket,
};

