const express = require('express');
const NotificationController = require('../controllers/notification_controller');
const authMiddleware = require('../middleware/auth_middleware');

const router = express.Router();
router.use(authMiddleware);

router.get('/', NotificationController.list);
router.patch('/:id/read', NotificationController.markAsRead);
router.post('/read-all', NotificationController.markAllAsRead);
router.delete('/:id', NotificationController.deleteSingle);
router.post('/batch-delete', NotificationController.deleteMultiple);

module.exports = router;

