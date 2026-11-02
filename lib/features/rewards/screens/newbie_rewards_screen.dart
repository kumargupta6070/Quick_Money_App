import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/custom_snackbar.dart';

class NewbieRewardsScreen extends StatelessWidget {
  const NewbieRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Newbie Rewards'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB45309), Color(0xFFF59E0B)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.gift, size: 48, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Welcome Bonus ₹50',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Complete your first PhonePe deposit to claim your starter investment package.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildTaskTile(
            context: context,
            title: 'Verify Mobile Number',
            reward: '₹10.00 RP',
            isCompleted: true,
          ),
          const SizedBox(height: 10),
          _buildTaskTile(
            context: context,
            title: 'Bind PhonePe UPI Address',
            reward: '₹20.00 RP',
            isCompleted: true,
          ),
          const SizedBox(height: 10),
          _buildTaskTile(
            context: context,
            title: 'Receive First L1 RP Order',
            reward: '₹20.00 RP',
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile({
    required BuildContext context,
    required String title,
    required String reward,
    required bool isCompleted,
  }) {
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
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Reward: $reward',
                style: const TextStyle(
                  color: AppColors.profitGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
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
                    style: TextStyle(
                      color: AppColors.profitGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              : ElevatedButton(
                  onPressed: () {
                    CustomSnackBar.showInfo(
                      context: context,
                      message: 'Navigate to Buy RP to fulfill this requirement.',
                    );
                  },
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

