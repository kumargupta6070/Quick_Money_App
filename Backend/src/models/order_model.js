const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Order = sequelize.define(
  'Order',
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    seller_id: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    buyer_id: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    order_amount: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
    order_quantity: {
      type: DataTypes.INTEGER,
      defaultValue: 1,
    },
    reward: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
    bonus: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 2.0,
    },
    final_rp: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
    level: {
      type: DataTypes.ENUM('L1', 'L2', 'L3', 'L4', 'L5', 'L6', 'L7'),
      defaultValue: 'L1',
    },
    utr_number: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    package_name: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    status: {
      type: DataTypes.ENUM('pending', 'active', 'received', 'completed', 'cancelled', 'rejected', 'paused'),
      defaultValue: 'active',
    },
  },
  {
    tableName: 'orders',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'completed_at',
  }
);

module.exports = Order;

