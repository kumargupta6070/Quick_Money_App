const { verifyAccessToken } = require('../utils/jwt_helper');
const ResponseHandler = require('../utils/response_handler');

function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return ResponseHandler.error(res, 'Authorization token required', 401);
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = verifyAccessToken(token);
    req.user = decoded;
    next();
  } catch (err) {
    return ResponseHandler.error(res, 'Invalid or expired token', 401);
  }
}

module.exports = authMiddleware;

