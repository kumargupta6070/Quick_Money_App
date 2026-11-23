const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Otp = sequelize.define(
  'Otp',
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    email: {
      type: DataTypes.STRING(191),
      allowNull: false,
    },
    otp_code: {
      type: DataTypes.STRING(6),
      allowNull: false,
    },
    type: {
      type: DataTypes.ENUM('register', 'login', 'forgot_password'),
      defaultValue: 'register',
    },
    expires_at: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    is_used: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
  },
  {
    tableName: 'otps',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    indexes: [
      {
        fields: ['email'],
      },
      {
        fields: ['otp_code'],
      },
    ],
  }
);

module.exports = Otp;

