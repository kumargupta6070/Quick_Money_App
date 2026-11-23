const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const { decrypt } = require('../config/encryption');

const Transaction = sequelize.define(
  'Transaction',
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
    order_id: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    type: {
      type: DataTypes.ENUM('buy', 'sell', 'deposit', 'withdrawal', 'payout', 'rebate', 'reward'),
      allowNull: false,
    },
    amount: {
      type: DataTypes.DECIMAL(12, 2),
      allowNull: false,
    },
    profit: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0.0,
    },
    payment_method: {
      type: DataTypes.ENUM('phonepe', 'googlepay', 'paytm'),
      defaultValue: 'phonepe',
    },
    payment_source_encrypted: {
      type: DataTypes.STRING,
      allowNull: true,
      comment: 'Encrypted VPA/Account from which user deposited funds',
    },
    payment_destination_encrypted: {
      type: DataTypes.STRING,
      allowNull: true,
      comment: 'Encrypted VPA/Account to which investment + profit was returned',
    },
    payment_reference_encrypted: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    status: {
      type: DataTypes.ENUM('pending', 'processing', 'completed', 'failed'),
      defaultValue: 'completed',
    },
  },
  {
    tableName: 'transactions',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: false,
  }
);

Transaction.prototype.getDecryptedSource = function () {
  return decrypt(this.payment_source_encrypted);
};

Transaction.prototype.getDecryptedDestination = function () {
  return decrypt(this.payment_destination_encrypted);
};

module.exports = Transaction;

