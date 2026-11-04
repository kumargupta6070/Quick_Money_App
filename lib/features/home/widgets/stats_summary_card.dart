import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/kpi_card.dart';

/// Next-Level 2x2 Performance Metrics Grid directly matching the ICU Mobile App KPI architecture.
/// Replaces flat grey lists with vivid, glowing, interactive KPI cards with staggered entry.
class StatsSummaryCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const StatsSummaryCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final buyQty = stats['buyQuantity'] ?? 1;
    final buyAmount = stats['buyAmount'] ?? 1550;
    final sellToday = stats['sellToday'] ?? 1599;
    final totalRevenue = stats['totalRevenue'] ?? 38.75;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Live Status & "More Details >" link
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.profitGreen,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.profitGreen,
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fade(begin: 0.3, end: 1.0, duration: 600.ms),
                  const SizedBox(width: 8),
                  Text(
                    'PORTFOLIO METRICS',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.9)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => context.push('/daily-details'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'More Details',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? const Color(0xFF38BDF8)
                              : AppColors.brandPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 14,
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : AppColors.brandPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.08, end: 0),

        // 2x2 Grid of ICU-Style Vivid KPI Cards
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.08,
          children: [
            KpiCard(
              title: 'Buy Quantity',
              value: '$buyQty Order',
              icon: LucideIcons.calendar,
              color: const Color(0xFF0284C7), // Sky Blue
              subtitle: 'Active today',
              trend: 'L1 Tier',
              index: 0,
              onTap: () => context.go('/buy-rp'),
            ),
            KpiCard(
              title: 'Buy Amount',
              value: '₹$buyAmount',
              icon: LucideIcons.receipt,
              color: const Color(0xFFD97706), // Amber Gold
              subtitle: 'Committed funds',
              trend: 'Secured',
              index: 1,
              onTap: () => context.push('/daily-details'),
            ),
            KpiCard(
              title: 'Sell Today',
              value: '₹$sellToday',
              icon: LucideIcons.refreshCw,
              color: const Color(0xFF0891B2), // Deep Ocean Cyan (High contrast)
              subtitle: 'Auto-return target',
              trend: '+₹49 return',
              index: 2,
              onTap: () => context.go('/sell-rp'),
            ),
            KpiCard(
              title: 'Total Revenue',
              value: '+₹$totalRevenue',
              icon: LucideIcons.trendingUp,
              color: const Color(0xFF059669), // Emerald Green
              subtitle: 'Daily net gain',
              trend: '+2.5% yield',
              index: 3,
              onTap: () => context.push('/daily-details'),
            ),
          ],
        ),
      ],
    );
  }
}
