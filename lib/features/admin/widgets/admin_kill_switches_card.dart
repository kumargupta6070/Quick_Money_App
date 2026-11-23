import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/utils/custom_snackbar.dart';

/// Emergency Circuit Breakers (Kill-Switches) Card for Super Admin Control.
class AdminKillSwitchesCard extends StatelessWidget {
  final bool isDark;
  final bool marketOnline;
  final bool payoutLockdown;
  final bool maintenanceMode;
  final ValueChanged<bool> onMarketToggle;
  final ValueChanged<bool> onPayoutLockdownToggle;
  final ValueChanged<bool> onMaintenanceToggle;

  const AdminKillSwitchesCard({
    super.key,
    required this.isDark,
    required this.marketOnline,
    required this.payoutLockdown,
    required this.maintenanceMode,
    required this.onMarketToggle,
    required this.onPayoutLockdownToggle,
    required this.onMaintenanceToggle,
  });

  Widget _buildSwitchRow({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: activeColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: activeColor,
            onChanged: (newVal) {
              HapticFeedback.mediumImpact();
              onChanged(newVal);
              CustomSnackBar.showTopSuccess(
                context: context,
                message: '$title switched to ${newVal ? "ENABLED" : "DISABLED"}',
                icon: LucideIcons.sliders,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF231017), Color(0xFF15080E)]
              : const [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFF43F5E).withValues(alpha: isDark ? 0.45 : 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF43F5E).withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.shieldAlert, color: Color(0xFFEF4444), size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Emergency Circuit Breakers',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSwitchRow(
            context: context,
            title: 'Market Trading Status',
            subtitle: marketOnline ? 'Traders can buy & sell RP' : 'Trading halted across platform',
            value: marketOnline,
            onChanged: onMarketToggle,
            activeColor: const Color(0xFF10B981),
            icon: LucideIcons.activity,
          ),
          _buildSwitchRow(
            context: context,
            title: 'Payout Lockdown',
            subtitle: payoutLockdown ? 'Withdrawals locked for audit' : 'Automated payouts normal',
            value: payoutLockdown,
            onChanged: onPayoutLockdownToggle,
            activeColor: const Color(0xFFEF4444),
            icon: LucideIcons.lock,
          ),
          _buildSwitchRow(
            context: context,
            title: 'Maintenance Mode',
            subtitle: maintenanceMode ? 'App shows maintenance banner' : 'Platform live for all traders',
            value: maintenanceMode,
            onChanged: onMaintenanceToggle,
            activeColor: const Color(0xFFF59E0B),
            icon: LucideIcons.wrench,
          ),
        ],
      ),
    );
  }
}
