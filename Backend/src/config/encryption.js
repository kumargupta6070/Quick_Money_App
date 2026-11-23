const crypto = require('crypto');

const ALGORITHM = 'aes-256-cbc';

function parseKey(rawKey) {
  if (!rawKey) return Buffer.from('quick_money_aes_256_secret_key_32bytes!'.slice(0, 32));
  if (rawKey.length === 64 && /^[0-9a-fA-F]+$/.test(rawKey)) {
    return Buffer.from(rawKey, 'hex');
  }
  return Buffer.from(rawKey.padEnd(32).slice(0, 32), 'utf8');
}

function parseIv(rawIv) {
  if (!rawIv) return Buffer.from('quick_money_iv_16b!'.slice(0, 16));
  if (rawIv.length === 32 && /^[0-9a-fA-F]+$/.test(rawIv)) {
    return Buffer.from(rawIv, 'hex');
  }
  return Buffer.from(rawIv.padEnd(16).slice(0, 16), 'utf8');
}

const SECRET_KEY = parseKey(process.env.AES_SECRET_KEY);
const IV = parseIv(process.env.AES_IV);

function encrypt(text) {
  if (!text) return text;
  const cipher = crypto.createCipheriv(ALGORITHM, SECRET_KEY, IV);
  let encrypted = cipher.update(String(text), 'utf8', 'hex');
  encrypted += cipher.final('hex');
  return encrypted;
}

function decrypt(encryptedText) {
  if (!encryptedText) return encryptedText;
  try {
    const decipher = crypto.createDecipheriv(ALGORITHM, SECRET_KEY, IV);
    let decrypted = decipher.update(String(encryptedText), 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
  } catch (err) {
    return encryptedText;
  }
}

module.exports = {
  encrypt,
  decrypt,
  parseKey,
  parseIv,
};

