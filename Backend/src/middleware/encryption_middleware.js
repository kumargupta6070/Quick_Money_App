const { decrypt, encrypt } = require('../utils/crypto_helper');

function encryptionMiddleware(req, res, next) {
  // If request contains an encrypted_payload field, decrypt it into req.body
  if (req.body && req.body.encrypted_payload) {
    try {
      const decryptedString = decrypt(req.body.encrypted_payload);
      req.body = JSON.parse(decryptedString);
    } catch (e) {
      // Keep plain body if format is raw JSON
    }
  }

  // Intercept json responses if client requested encrypted transport
  const originalJson = res.json;
  res.json = function (body) {
    if (req.headers['x-encrypt-response'] === 'true' && body && body.data) {
      try {
        const encrypted = encrypt(JSON.stringify(body.data));
        body.data = { encrypted_data: encrypted };
      } catch (err) {
        // Fallback to unencrypted
      }
    }
    return originalJson.call(this, body);
  };

  next();
}

module.exports = encryptionMiddleware;

