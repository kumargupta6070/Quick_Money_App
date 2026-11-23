const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const { encrypt, decrypt } = require('../config/encryption');

const User = sequelize.define(
  'User',
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    mobile_encrypted: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    mobile_hash: {
      type: DataTypes.STRING(64),
      allowNull: true,
    },
    email: {
      type: DataTypes.STRING(191),
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true,
      },
    },
    password_hash: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    invite_code: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    referred_by: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    role: {
      type: DataTypes.ENUM('user', 'admin'),
      defaultValue: 'user',
    },
    balance: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 51.07,
    },
    level: {
      type: DataTypes.ENUM('L1', 'L2', 'L3', 'L4', 'L5', 'L6', 'L7'),
      defaultValue: 'L1',
    },
    status: {
      type: DataTypes.ENUM('active', 'suspended', 'banned'),
      defaultValue: 'active',
    },
    is_email_verified: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
  },
  {
    tableName: 'users',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  }
);

User.prototype.getDecryptedMobile = function () {
  return decrypt(this.mobile_encrypted);
};

module.exports = User;
