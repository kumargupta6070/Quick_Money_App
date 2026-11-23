const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const AuditLog = sequelize.define('AuditLog', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  admin_id: {
    type: DataTypes.INTEGER,
    allowNull: true,
  },
  action: {
    type: DataTypes.STRING(64),
    allowNull: false,
  },
  target_type: {
    type: DataTypes.STRING(64),
    allowNull: true,
  },
  target_id: {
    type: DataTypes.STRING(64),
    allowNull: true,
  },
  details: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  ip_address: {
    type: DataTypes.STRING(64),
    allowNull: true,
  },
}, {
  tableName: 'audit_logs',
  timestamps: true,
  underscored: true,
});

module.exports = AuditLog;
