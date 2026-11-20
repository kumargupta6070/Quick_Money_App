import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/utils/currency_formatter.dart';

/// Platform Financial Metrics (2x2 Grid)
class AdminFinancialMetricsGrid extends StatelessWidget {
  final AdminStats stats;
  final bool isDark;

  const AdminFinancialMetricsGrid({
    super.key,
    required this.stats,
    required this.isDark,
  });

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.12 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 13, color: accentColor),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'FINANCIAL HEALTH & PLATFORM VOLUME',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.35,
          children: [
            _buildMetricTile(
              label: 'Total Platform Volume',
              value: CurrencyFormatter.format(stats.totalPlatformVolume),
              subtitle: '${stats.totalOrders} total market orders',
              icon: LucideIcons.trendingUp,
              accentColor: const Color(0xFF0284C7),
              isDark: isDark,
            ),
            _buildMetricTile(
              label: 'Active User Balance',
              value: CurrencyFormatter.format(stats.totalUserBalanceFloat),
              subtitle: '${stats.activeUsers} active retail traders',
              icon: LucideIcons.wallet,
              accentColor: const Color(0xFF10B981),
              isDark: isDark,
            ),
            _buildMetricTile(
              label: 'Settled PhonePe Returns',
              value: CurrencyFormatter.format(stats.totalPayoutsSettled),
              subtitle: '100% automated payouts',
              icon: LucideIcons.shieldCheck,
              accentColor: const Color(0xFF8B5CF6),
              isDark: isDark,
            ),
            _buildMetricTile(
              label: 'Active Market Packages',
              value: '${stats.activePackages} Packages',
              subtitle: '${stats.completedOrders} completed trades',
              icon: LucideIcons.package,
              accentColor: const Color(0xFFF59E0B),
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }
}
