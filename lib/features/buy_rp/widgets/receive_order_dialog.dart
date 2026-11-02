import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/order_model.dart';

class ReceiveOrderDialog extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onConfirm;

  const ReceiveOrderDialog({
    super.key,
    required this.order,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Confirm Receive Order', style: TextStyle(fontWeight: FontWeight.w700)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Amount: ₹${order.orderAmount}'),
          const SizedBox(height: 6),
          Text('Expected Reward: ₹${order.reward} + bonus ₹${order.bonus}'),
          const SizedBox(height: 6),
          Text('Final RP: ${order.finalRp} RP', style: const TextStyle(color: AppColors.profitGreen, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          const Text(
            'Once profit reaches ₹100, money is automatically returned to your bound PhonePe UPI ID!',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

