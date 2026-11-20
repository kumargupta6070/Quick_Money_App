import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NotificationOverviewBar extends StatelessWidget {
  final int totalCount;
  final int unreadCount;
  final double totalEarnings;
  final bool isDark;

  const NotificationOverviewBar({
    super.key,
    required this.totalCount,
    required this.unreadCount,
    required this.totalEarnings,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF132247),
                  const Color(0xFF0C1630),
                  const Color(0xFF162854),
                ]
              : [
                  const Color(0xFFEFF8FF),
                  const Color(0xFFE0F2FE),
                  const Color(0xFFF0FDF4),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0xFF38BDF8).withValues(alpha: 0.35)
              : const Color(0xFF0284C7).withValues(alpha: 0.28),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7)
                .withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatPill(
            label: 'Total Alerts',
            value: '$totalCount',
            color: const Color(0xFF0284C7),
            icon: LucideIcons.bellRing,
          ),
          Container(
            width: 1,
            height: 26,
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFCBD5E1),
          ),
          _buildStatPill(
            label: 'Pending',
            value: '$unreadCount New',
            color: const Color(0xFFEF4444),
            icon: LucideIcons.sparkle,
          ),
          Container(
            width: 1,
            height: 26,
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFCBD5E1),
          ),
          _buildStatPill(
            label: 'Total Credited',
            value: '+₹${totalEarnings.toStringAsFixed(2)}',
            color: const Color(0xFF10B981),
            icon: LucideIcons.wallet,
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
