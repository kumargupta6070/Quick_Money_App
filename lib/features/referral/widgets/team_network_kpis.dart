import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/referral_provider.dart';
import '../../../core/utils/currency_formatter.dart';

/// Network KPI Metrics: 3 FinTech mini tiles with vibrant gradients and staggered animations
class TeamNetworkKpis extends StatelessWidget {
  final bool isDark;
  final TeamOverview team;

  const TeamNetworkKpis({
    super.key,
    required this.isDark,
    required this.team,
  });

  Widget _buildMiniKpi({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Color> gradientColors,
    required int delayMs,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => HapticFeedback.lightImpact(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                Icon(icon, size: 15, color: isDark ? Colors.white : color),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.35)
                          : color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
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
                value,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14.5,
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
    final totalMembers = team.level1Members + team.level2Members + team.level3Members;

    return Row(
      children: [
        Expanded(
          child: _buildMiniKpi(
            title: 'Direct Team',
            value: '${team.level1Members} Users',
            subtitle: '${team.level1Percent} Tier',
            icon: LucideIcons.userPlus,
            color: const Color(0xFF0284C7),
            gradientColors: isDark
                ? [const Color(0xFF082F49), const Color(0xFF0C4A6E)]
                : [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)],
            delayMs: 80,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniKpi(
            title: 'Network Size',
            value: '$totalMembers Users',
            subtitle: '3 Tiers',
            icon: LucideIcons.network,
            color: const Color(0xFF8B5CF6),
            gradientColors: isDark
                ? [const Color(0xFF2E1065), const Color(0xFF3B0764)]
                : [const Color(0xFFF3E8FF), const Color(0xFFE9D5FF)],
            delayMs: 140,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniKpi(
            title: 'Daily Volume',
            value: CurrencyFormatter.format(team.dailyVolume),
            subtitle: 'Active RP',
            icon: LucideIcons.trendingUp,
            color: const Color(0xFF10B981),
            gradientColors: isDark
                ? [const Color(0xFF064E3B), const Color(0xFF065F46)]
                : [const Color(0xFFD1FAE5), const Color(0xFFA7F3D0)],
            delayMs: 200,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}
