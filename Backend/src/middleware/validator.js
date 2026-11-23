const { validationResult } = require('express-validator');
const ResponseHandler = require('../utils/response_handler');

function validate(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return ResponseHandler.error(
      res,
      'Validation failed',
      422,
      errors.array().map((err) => ({ field: err.path, message: err.msg }))
    );
  }
  next();
}

module.exports = validate;

