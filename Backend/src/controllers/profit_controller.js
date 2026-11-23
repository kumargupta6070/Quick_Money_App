const ProfitCalculator = require('../services/profit_calculator');
const ResponseHandler = require('../utils/response_handler');

class ProfitController {
  static async getDailyDetails(req, res) {
    try {
      const { date, filter } = req.query;
      const data = await ProfitCalculator.getDailySummary(req.user.id, date, filter);
      return ResponseHandler.success(res, data);
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }
}

module.exports = ProfitController;

