const ReferralService = require('../services/referral_service');
const ResponseHandler = require('../utils/response_handler');

class ReferralController {
  static async getTeam(req, res) {
    try {
      const data = await ReferralService.getTeamOverview(req.user.id);
      return ResponseHandler.success(res, data);
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async getTierMembers(req, res) {
    try {
      const { tier } = req.query;
      const members = await ReferralService.getTierMembers(req.user.id, tier);
      return ResponseHandler.success(res, members, `Tier ${tier || 'L1'} team members loaded`);
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }
}

module.exports = ReferralController;

