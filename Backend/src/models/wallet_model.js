const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const { decrypt } = require('../config/encryption');

const Wallet = sequelize.define(
  'Wallet',
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
    payment_app: {
      type: DataTypes.ENUM('phonepe', 'googlepay', 'paytm'),
      defaultValue: 'phonepe',
    },
    upi_id_encrypted: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    account_name_encrypted: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    status: {
      type: DataTypes.ENUM('active', 'warning', 'abnormal'),
      defaultValue: 'active',
    },
    status_detail: {
      type: DataTypes.STRING,
      defaultValue: 'Verified',
    },
  },
  {
    tableName: 'wallets',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: false,
  }
);

Wallet.prototype.getDecryptedUpi = function () {
  return decrypt(this.upi_id_encrypted);
};

module.exports = Wallet;

