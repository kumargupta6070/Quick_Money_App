import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import 'admin_screen_hero_header.dart';

/// Royal SuperAdmin Hero Header for the main Overview tab.
/// Embeds HomeHeader and presents platform metrics chips.
class AdminHeroHeader extends StatelessWidget {
  final bool isDark;
  final AdminStats stats;

  const AdminHeroHeader({
    super.key,
    required this.isDark,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return AdminScreenHeroHeader(
      title: 'Super Admin Command',
      icon: LucideIcons.crown,
      badgeText: stats.marketStatus,
      badgeColor: stats.marketStatus == 'ONLINE'
          ? const Color(0xFF10B981)
          : const Color(0xFFEF4444),
      bottom: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Clearance Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.shieldAlert,
                  color: Color(0xFF78350F),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PLATFORM COMMAND CENTER',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Super Admin • Full System Authority',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF38BDF8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Live Quick Metrics Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildQuickMetricPill(
                  icon: LucideIcons.users,
                  label: 'Traders',
                  value: '${stats.totalUsers}',
                  color: const Color(0xFF38BDF8),
                ),
                const SizedBox(width: 8),
                _buildQuickMetricPill(
                  icon: LucideIcons.package2,
                  label: 'Active Packages',
                  value: '${stats.activePackages}',
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(width: 8),
                _buildQuickMetricPill(
                  icon: LucideIcons.arrowDownToLine,
                  label: 'Pending Payouts',
                  value: '${stats.pendingPayoutsCount}',
                  color: stats.pendingPayoutsCount > 0
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                ),
                const SizedBox(width: 8),
                _buildQuickMetricPill(
                  icon: LucideIcons.trendingUp,
                  label: 'Platform Net',
                  value: CurrencyFormatter.format(stats.totalPlatformVolume),
                  color: const Color(0xFFF59E0B),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.05, end: 0),
        ],
      ),
    );
  }

  Widget _buildQuickMetricPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
