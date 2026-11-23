const NotificationService = require('../services/notification_service');
const ResponseHandler = require('../utils/response_handler');

class NotificationController {
  static async list(req, res) {
    try {
      const data = await NotificationService.getUserNotifications(req.user.id);
      return ResponseHandler.success(res, data);
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async markAsRead(req, res) {
    try {
      const { id } = req.params;
      await NotificationService.markAsRead(id, req.user.id);
      return ResponseHandler.success(res, null, 'Notification marked as read');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async markAllAsRead(req, res) {
    try {
      await NotificationService.markAllAsRead(req.user.id);
      return ResponseHandler.success(res, null, 'All notifications marked as read');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async deleteSingle(req, res) {
    try {
      const { id } = req.params;
      const success = await NotificationService.deleteSingle(id, req.user.id);
      if (!success) {
        return ResponseHandler.error(res, 'Notification not found or already deleted', 404);
      }
      return ResponseHandler.success(res, null, 'Notification deleted successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async deleteMultiple(req, res) {
    try {
      const { ids } = req.body;
      if (!ids || !Array.isArray(ids) || ids.length === 0) {
        return ResponseHandler.error(res, 'Array of notification ids is required', 400);
      }
      const count = await NotificationService.deleteMultiple(ids, req.user.id);
      return ResponseHandler.success(res, { count }, `${count} notifications deleted successfully`);
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }
}

module.exports = NotificationController;

