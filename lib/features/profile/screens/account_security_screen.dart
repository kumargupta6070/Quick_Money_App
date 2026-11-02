import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/custom_snackbar.dart';

class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Account Security'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Security Level Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.shieldCheck, color: Colors.white, size: 44),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'AES-256 Protected',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your financial identity and payouts are encrypted at the highest security standard.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildSecurityTile(
            context: context,
            title: 'Change Login Password',
            subtitle: 'Recommended to update every 90 days',
            icon: LucideIcons.key,
            onTap: () {
              CustomSnackBar.showInfo(
                context: context,
                message: 'Password reset link sent to registered mobile via SMS.',
                icon: LucideIcons.key,
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSecurityTile(
            context: context,
            title: 'Two-Factor Authentication (OTP)',
            subtitle: 'Active for all payouts and withdrawals',
            icon: LucideIcons.smartphone,
            trailingText: 'ENABLED',
            onTap: null,
          ),
          const SizedBox(height: 12),
          _buildSecurityTile(
            context: context,
            title: 'Login Devices & Sessions',
            subtitle: '1 active device registered',
            icon: LucideIcons.laptop,
            onTap: () {
              CustomSnackBar.showSuccess(
                context: context,
                message: 'Current device is authorized and verified.',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.brandPrimary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.brandPrimary, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
        trailing: trailingText != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.profitGreenBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trailingText,
                  style: const TextStyle(
                    color: AppColors.profitGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            : const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }
}

