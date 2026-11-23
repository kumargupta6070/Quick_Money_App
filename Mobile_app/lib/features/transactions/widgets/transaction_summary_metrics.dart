import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Summary Metrics Bar with FinTech colorful gradients and zero overflow
class TransactionSummaryMetrics extends StatelessWidget {
  final bool isDark;

  const TransactionSummaryMetrics({super.key, required this.isDark});

  Widget _buildMetricTile({
    required String title,
    required String amount,
    required String subtitle,
    required Color color,
    required List<Color> gradientColors,
    required int delayMs,
    required IconData icon,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => HapticFeedback.lightImpact(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.45 : 0.35),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.25 : 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: isDark ? Colors.white : color),
                const SizedBox(width: 3),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3.5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.35)
                          : color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: delayMs.ms, duration: 400.ms)
        .scale(
          begin: const Offset(0.90, 0.90),
          delay: delayMs.ms,
          curve: Curves.easeOutBack,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            title: 'Payout Returns',
            amount: '+₹1,650.00',
            subtitle: 'PhonePe Auto',
            color: const Color(0xFF10B981),
            gradientColors: isDark
                ? [const Color(0xFF064E3B), const Color(0xFF065F46)]
                : [const Color(0xFFD1FAE5), const Color(0xFFA7F3D0)],
            delayMs: 80,
            icon: LucideIcons.arrowDownLeft,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            title: 'Money Added',
            amount: '₹1,595.00',
            subtitle: 'Order Capital',
            color: const Color(0xFF0284C7),
            gradientColors: isDark
                ? [const Color(0xFF082F49), const Color(0xFF0C4A6E)]
                : [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)],
            delayMs: 140,
            icon: LucideIcons.arrowUpRight,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            title: 'Net Profit',
            amount: '+₹183.75',
            subtitle: 'All Yields',
            color: const Color(0xFFF59E0B),
            gradientColors: isDark
                ? [const Color(0xFF451A03), const Color(0xFF78350F)]
                : [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
            delayMs: 200,
            icon: LucideIcons.zap,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}
