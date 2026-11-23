const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Referral = sequelize.define(
  'Referral',
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    referrer_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    referred_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    level: {
      type: DataTypes.INTEGER, // 1, 2, or 3
      allowNull: false,
    },
    total_rebate_earned: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0.0,
    },
  },
  {
    tableName: 'referrals',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: false,
  }
);

module.exports = Referral;

