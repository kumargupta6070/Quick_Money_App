const { Notification, User } = require('../models');

class NotificationService {
  static async send({ userId, title, message, type = 'system' }) {
    return Notification.create({
      user_id: userId,
      title,
      message,
      type,
      is_read: false,
    });
  }

  /**
   * Broadcast real-time platform notification to all SuperAdmins
   */
  static async notifyAdmins({ title, message, type = 'system' }) {
    try {
      const admins = await User.findAll({
        where: { role: 'admin' },
        attributes: ['id'],
      });
      if (!admins || admins.length === 0) return [];

      const notifications = await Promise.all(
        admins.map((adm) =>
          Notification.create({
            user_id: adm.id,
            title,
            message,
            type,
            is_read: false,
          })
        )
      );
      return notifications;
    } catch (err) {
      console.error('Failed to notify admins:', err.message);
      return [];
    }
  }

  static async getUserNotifications(userId) {
    return Notification.findAll({
      where: { user_id: userId },
      order: [['created_at', 'DESC']],
      limit: 100,
    });
  }

  static async markAsRead(id, userId) {
    await Notification.update(
      { is_read: true },
      { where: { id, user_id: userId } }
    );
    return true;
  }

  static async markAllAsRead(userId) {
    await Notification.update(
      { is_read: true },
      { where: { user_id: userId, is_read: false } }
    );
    return true;
  }

  static async deleteSingle(id, userId) {
    const deleted = await Notification.destroy({
      where: { id, user_id: userId },
    });
    return deleted > 0;
  }

  static async deleteMultiple(ids, userId) {
    if (!Array.isArray(ids) || ids.length === 0) return 0;
    const deletedCount = await Notification.destroy({
      where: {
        id: ids,
        user_id: userId,
      },
    });
    return deletedCount;
  }
}

module.exports = NotificationService;


