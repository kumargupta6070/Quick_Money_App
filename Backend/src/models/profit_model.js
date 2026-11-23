const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const DailyProfit = sequelize.define(
  'DailyProfit',
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    profit_date: {
      type: DataTypes.DATEONLY,
      allowNull: false,
    },
    total_income: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0.0,
    },
    purchase_number: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    purchase_amount: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0.0,
    },
    brokerage: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0.0,
    },
    team_rebates: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0.0,
    },
    subordinate_rebates: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0.0,
    },
    usdt_recharge: {
      type: DataTypes.DECIMAL(12, 4),
      defaultValue: 0.0,
    },
    trx_recharge: {
      type: DataTypes.DECIMAL(12, 4),
      defaultValue: 0.0,
    },
    sell_number: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    sell_amount: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0.0,
    },
    activity_reward: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0.0,
    },
    other_reward: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0.0,
    },
  },
  {
    tableName: 'daily_profits',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: false,
  }
);

module.exports = DailyProfit;

