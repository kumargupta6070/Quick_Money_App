const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const SupportTicket = sequelize.define('SupportTicket', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  ticket_number: {
    type: DataTypes.STRING(32),
    allowNull: false,
    unique: true,
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  user_email: {
    type: DataTypes.STRING(191),
    allowNull: true,
  },
  user_mobile: {
    type: DataTypes.STRING(32),
    allowNull: true,
  },
  category: {
    type: DataTypes.STRING(64),
    defaultValue: 'General Dispute',
  },
  subject: {
    type: DataTypes.STRING(191),
    allowNull: false,
  },
  message: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  status: {
    type: DataTypes.ENUM('open', 'replied', 'resolved'),
    defaultValue: 'open',
  },
  admin_reply: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  resolved_at: {
    type: DataTypes.DATE,
    allowNull: true,
  },
}, {
  tableName: 'support_tickets',
  timestamps: true,
  underscored: true,
});

module.exports = SupportTicket;
