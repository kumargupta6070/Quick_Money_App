const express = require('express');
const RewardController = require('../controllers/reward_controller');
const authMiddleware = require('../middleware/auth_middleware');

const router = express.Router();
router.use(authMiddleware);

router.get('/newbie', RewardController.getNewbieRewards);
router.post('/claim', RewardController.claimReward);

module.exports = router;
