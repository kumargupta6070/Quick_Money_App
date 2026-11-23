const express = require('express');
const ReferralController = require('../controllers/referral_controller');
const authMiddleware = require('../middleware/auth_middleware');

const router = express.Router();
router.use(authMiddleware);

router.get('/team', ReferralController.getTeam);
router.get('/team/members', ReferralController.getTierMembers);

module.exports = router;

