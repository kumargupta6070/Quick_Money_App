import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RewardCard extends StatelessWidget {
  final String title;
  final String reward;
  final bool isCompleted;
  final VoidCallback? onClaim;

  const RewardCard({
    super.key,
    required this.title,
    required this.reward,
    required this.isCompleted,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                'Reward: $reward',
                style: const TextStyle(color: AppColors.profitGreen, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          isCompleted
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.profitGreenBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'CLAIMED',
                    style: TextStyle(color: AppColors.profitGreen, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                )
              : ElevatedButton(
                  onPressed: onClaim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Go', style: TextStyle(fontSize: 12)),
                ),
        ],
      ),
    );
  }
}

