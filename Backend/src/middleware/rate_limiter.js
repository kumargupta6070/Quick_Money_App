const rateLimit = require('express-rate-limit');
const ResponseHandler = require('../utils/response_handler');

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 200, // limit each IP to 200 requests per windowMs
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    ResponseHandler.error(res, 'Too many requests, please try again later.', 429);
  },
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  handler: (req, res) => {
    ResponseHandler.error(res, 'Too many login attempts. Please wait 15 minutes.', 429);
  },
});

module.exports = {
  apiLimiter,
  authLimiter,
};

