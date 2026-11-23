const RewardService = require('../services/reward_service');
const ResponseHandler = require('../utils/response_handler');

class RewardController {
  static async getNewbieRewards(req, res) {
    try {
      const data = await RewardService.getNewbieRewards(req.user.id);
      return ResponseHandler.success(res, data, 'Newbie rewards fetched successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async claimReward(req, res) {
    try {
      const { taskId } = req.body;
      if (!taskId) {
        return ResponseHandler.error(res, 'taskId is required', 400);
      }
      const data = await RewardService.claimReward(req.user.id, taskId);
      return ResponseHandler.success(res, data, data.message);
    } catch (err) {
      return ResponseHandler.error(res, err.message, 400);
    }
  }
}

module.exports = RewardController;
