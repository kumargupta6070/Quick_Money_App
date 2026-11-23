const ResponseHandler = require('../utils/response_handler');

/**
 * Middleware to restrict access based on user role (e.g. ['admin'])
 */
function roleMiddleware(allowedRoles = ['admin']) {
  return (req, res, next) => {
    if (!req.user) {
      return ResponseHandler.error(res, 'Authentication required', 401);
    }

    if (!allowedRoles.includes(req.user.role)) {
      return ResponseHandler.error(
        res,
        'Access denied: Administrator privileges required.',
        403
      );
    }

    next();
  };
}

module.exports = roleMiddleware;
