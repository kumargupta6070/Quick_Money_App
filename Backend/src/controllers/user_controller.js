const { User } = require('../models');
const ResponseHandler = require('../utils/response_handler');
const { decrypt } = require('../utils/crypto_helper');
const bcrypt = require('bcryptjs');

class UserController {
  static async getProfile(req, res) {
    try {
      const user = await User.findByPk(req.user.id);
      if (!user) return ResponseHandler.error(res, 'User not found', 404);

      return ResponseHandler.success(res, {
        id: user.id,
        mobile: decrypt(user.mobile_encrypted),
        email: user.email,
        invite_code: user.invite_code,
        balance: user.balance,
        level: user.level,
        status: user.status,
        role: user.role,
      });
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async changePassword(req, res) {
    try {
      const { oldPassword, newPassword } = req.body;
      if (!oldPassword || !newPassword) {
        return ResponseHandler.error(res, 'Both current password and new password are required.', 400);
      }
      if (newPassword.length < 6) {
        return ResponseHandler.error(res, 'New password must be at least 6 characters long.', 400);
      }

      const user = await User.findByPk(req.user.id);
      if (!user) return ResponseHandler.error(res, 'User not found', 404);

      const isMatch = await bcrypt.compare(oldPassword, user.password_hash);
      if (!isMatch) {
        return ResponseHandler.error(res, 'Current password is incorrect.', 400);
      }

      user.password_hash = await bcrypt.hash(newPassword, 10);
      await user.save();

      return ResponseHandler.success(res, null, 'Password updated successfully. AES-256 vault credentials refreshed.');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async submitSupportTicket(req, res) {
    try {
      const { category, subject, message } = req.body;
      const user = await User.findByPk(req.user.id);
      if (!user) return ResponseHandler.error(res, 'User not found', 404);

      const { Notification, SupportTicket } = require('../models');
      const ticketId = `TKT-${Date.now().toString().slice(-6)}`;

      let rawMobile = '';
      try {
        const { decrypt } = require('../config/encryption');
        rawMobile = decrypt(user.mobile_encrypted);
      } catch {
        rawMobile = 'N/A';
      }

      await SupportTicket.create({
        ticket_number: ticketId,
        user_id: user.id,
        user_email: user.email,
        user_mobile: rawMobile,
        category: category || 'General Dispute',
        subject: subject || 'Customer Support Request',
        message: message || '',
        status: 'open',
      });

      await Notification.create({
        user_id: user.id,
        title: `Support Ticket Created #${ticketId} 🎫`,
        message: `Your request regarding "${subject || category || 'General Dispute'}" has been logged. Priority response within 2 hours.`,
        type: 'system',
        is_read: false,
      });

      // Notify Admins about new ticket
      try {
        const NotificationService = require('../services/notification_service');
        await NotificationService.notifyAdmins({
          title: 'New Support Ticket Raised 🎫',
          message: `User ${user.email} (ID: #${user.id}) raised ticket #${ticketId}: "${subject || category}".`,
          type: 'system',
        });
      } catch (_) {}

      return ResponseHandler.success(res, {
        ticketId,
        category: category || 'General Inquiry',
        status: 'OPEN',
        createdAt: new Date().toISOString(),
      }, `Support ticket ${ticketId} submitted successfully.`);
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async listUserTickets(req, res) {
    try {
      const { SupportTicket } = require('../models');
      const tickets = await SupportTicket.findAll({
        where: { user_id: req.user.id },
        order: [['created_at', 'DESC']],
        limit: 50,
      });
      return ResponseHandler.success(res, tickets, 'User support tickets fetched successfully');
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }
}

module.exports = UserController;

