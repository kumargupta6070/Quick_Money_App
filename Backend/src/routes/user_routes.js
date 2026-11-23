const express = require('express');
const UserController = require('../controllers/user_controller');
const authMiddleware = require('../middleware/auth_middleware');

const router = express.Router();
router.use(authMiddleware);

router.get('/profile', UserController.getProfile);
router.post('/change-password', UserController.changePassword);
router.post('/support-ticket', UserController.submitSupportTicket);
router.get('/my-tickets', UserController.listUserTickets);

module.exports = router;

