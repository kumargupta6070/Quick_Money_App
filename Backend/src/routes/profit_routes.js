const express = require('express');
const ProfitController = require('../controllers/profit_controller');
const authMiddleware = require('../middleware/auth_middleware');

const router = express.Router();
router.use(authMiddleware);

router.get('/daily-details', ProfitController.getDailyDetails);

module.exports = router;

