const { Order, User, Transaction } = require('../models');
const AutoPayoutService = require('../services/auto_payout_service');
const ResponseHandler = require('../utils/response_handler');

class OrderController {
  static async listOrders(req, res) {
    try {
      const level = req.query.level || 'L1';
      const sort = req.query.sort === 'high_to_low' ? 'DESC' : 'ASC';

      const orders = await Order.findAll({
        where: { level, status: 'active' },
        order: [['order_amount', sort]],
      });

      return ResponseHandler.success(res, orders);
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  static async receiveOrder(req, res) {
    try {
      const { orderId } = req.params;
      const order = await Order.findByPk(orderId);
      if (!order || order.status !== 'active') {
        return ResponseHandler.error(res, 'Order is no longer available', 400);
      }

      // If available quantity > 1, decrement available pool; otherwise mark complete
      if (order.order_quantity > 1) {
        await order.decrement('order_quantity', { by: 1 });
        await order.reload();
      } else {
        await order.update({
          buyer_id: req.user.id,
          status: 'completed',
        });
      }

      // Record transaction
      const totalProfit = parseFloat(order.reward) + parseFloat(order.bonus);
      await Transaction.create({
        user_id: req.user.id,
        order_id: order.id,
        type: 'buy',
        amount: order.order_amount,
        profit: totalProfit,
        payment_method: 'phonepe',
        status: 'completed',
      });

      // Credit profit to user
      const user = await User.findByPk(req.user.id);
      if (user) {
        await user.increment('balance', { by: totalProfit });
      }

      // Check if profit >= ₹100 threshold for PhonePe return payout
      const payoutCheck = await AutoPayoutService.processEligiblePayouts();

      // Dispatch in-app notifications to User & Admin
      try {
        const NotificationService = require('../services/notification_service');
        await Promise.allSettled([
          NotificationService.send({
            userId: req.user.id,
            title: 'RP Package Executed ⚡',
            message: `Order #${order.id} purchased for ₹${order.order_amount}. Profit of ₹${totalProfit.toFixed(2)} credited to your vault.`,
            type: 'order',
          }),
          NotificationService.notifyAdmins({
            title: 'RP Order Bought 📦',
            message: `User ${user ? user.email : `#${req.user.id}`} bought RP Order #${order.id} (₹${order.order_amount}). Profit: ₹${totalProfit.toFixed(2)}.`,
            type: 'order',
          }),
        ]);
      } catch (_) {}

      return ResponseHandler.success(res, {
        order,
        payoutCheck,
      }, `Order received successfully! ₹${totalProfit.toFixed(2)} profit credited.`);
    } catch(err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }

  /**
   * Submit manual UTR deposit reference for Admin verification
   */
  static async submitUtrDeposit(req, res) {
    try {
      const { amount, utrNumber, packageName } = req.body;
      const cleanAmount = parseFloat(amount);
      const cleanUtr = String(utrNumber || '').trim();

      if (!cleanAmount || cleanAmount <= 0) {
        return ResponseHandler.error(res, 'Valid deposit amount is required', 400);
      }
      if (!cleanUtr || cleanUtr.length < 8) {
        return ResponseHandler.error(res, 'Valid 12-digit Bank UTR / UPI Reference is required', 400);
      }

      const user = await User.findByPk(req.user.id);
      if (!user) return ResponseHandler.error(res, 'User not found', 404);

      // Create pending order with UTR
      const pendingOrder = await Order.create({
        buyer_id: user.id,
        order_amount: cleanAmount,
        order_quantity: 1,
        reward: (cleanAmount * 0.02).toFixed(2),
        bonus: (cleanAmount * 0.005).toFixed(2),
        level: user.level || 'L1',
        package_name: packageName || `RP Deposit ₹${cleanAmount}`,
        status: 'pending',
        utr_number: cleanUtr,
      });

      // Dispatch in-app notifications to User and Admin
      try {
        const NotificationService = require('../services/notification_service');
        await Promise.allSettled([
          NotificationService.send({
            userId: user.id,
            title: 'Deposit UTR Submitted ⏳',
            message: `Your deposit of ₹${cleanAmount} with UTR ${cleanUtr} has been logged. Admin verification in progress.`,
            type: 'order',
          }),
          NotificationService.notifyAdmins({
            title: 'New UTR Deposit Submitted 💰',
            message: `User ${user.email} (ID: #${user.id}) submitted UTR ${cleanUtr} for ₹${cleanAmount}. Please verify in UTR Queue.`,
            type: 'order',
          }),
        ]);
      } catch (_) {}

      return ResponseHandler.success(
        res,
        pendingOrder,
        'UTR deposit submitted successfully! Live desk verification under 15 minutes.'
      );
    } catch (err) {
      return ResponseHandler.error(res, err.message, 500);
    }
  }
}

module.exports = OrderController;

