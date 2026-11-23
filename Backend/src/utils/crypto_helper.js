const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const { encrypt, decrypt } = require('../config/encryption');

async function hashPassword(plainPassword) {
  const salt = await bcrypt.genSalt(10);
  return bcrypt.hash(plainPassword, salt);
}

async function comparePassword(plainPassword, hashedPassword) {
  return bcrypt.compare(plainPassword, hashedPassword);
}

function hashMobile(mobile) {
  const cleanMobile = String(mobile).replace(/\D/g, '');
  return crypto.createHash('sha256').update(cleanMobile).digest('hex');
}

module.exports = {
  hashPassword,
  comparePassword,
  hashMobile,
  encrypt,
  decrypt,
};
