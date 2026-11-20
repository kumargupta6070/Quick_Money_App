import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../shared/models/daily_detail_model.dart';
import '../../../core/utils/currency_formatter.dart';
import 'daily_metrics_helper.dart';

class DailySaleAndRewardsSection extends StatelessWidget {
  final DailyDetailModel detail;
  final bool isDark;

  const DailySaleAndRewardsSection({
    super.key,
    required this.detail,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Data for Sale Section
        _buildDataForSale(context),

        const SizedBox(height: 14),

        // 2. Platform Rewards Section
        _buildPlatformRewards(context),

        const SizedBox(height: 18),

        // 3. Quick Action Buttons
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildDataForSale(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF450A19), Color(0xFF24030D)]
              : const [Color(0xFFFFF1F2), Color(0xFFFFE4E6), Color(0xFFFEF2F2)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xFFF43F5E).withValues(alpha: 0.40)
              : const Color(0xFFF43F5E).withValues(alpha: 0.32),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF43F5E)
                .withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DailySectionTitle(
            icon: LucideIcons.repeat,
            title: 'Data for Sale',
            badge: 'Sell RP Liquidity',
            accentColor: const Color(0xFFEF4444),
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              DailyMetricTile(
                label: 'Completed Sales',
                value: detail.sellNumber == 1
                    ? '1 Order'
                    : '${detail.sellNumber} Orders',
                icon: LucideIcons.checkCircle2,
                accentColor: const Color(0xFFEF4444),
                customGradient: isDark
                    ? const [Color(0xFF450A19), Color(0xFF24030D)]
                    : const [
                        Color(0xFFFFF1F2),
                        Color(0xFFFFE4E6),
                        Color(0xFFFEE2E2),
                      ],
                delayMs: 460,
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              DailyMetricTile(
                label: 'Realized Value',
                value: CurrencyFormatter.format(detail.sellAmount),
                icon: LucideIcons.coins,
                accentColor: const Color(0xFF10B981),
                customGradient: isDark
                    ? const [Color(0xFF063B2B), Color(0xFF032218)]
                    : const [
                        Color(0xFFECFDF5),
                        Color(0xFFD1FAE5),
                        Color(0xFFDCFCE7),
                      ],
                isHighlight: true,
                delayMs: 500,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformRewards(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF3F1B05), Color(0xFF220E02)]
              : const [Color(0xFFFFFBEB), Color(0xFFFEF3C7), Color(0xFFFFF7ED)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xFFF59E0B).withValues(alpha: 0.45)
              : const Color(0xFFF59E0B).withValues(alpha: 0.35),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B)
                .withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DailySectionTitle(
            icon: LucideIcons.gift,
            title: 'Platform Rewards',
            badge: 'Community Pool',
            accentColor: const Color(0xFFF59E0B),
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              DailyMetricTile(
                label: 'Activity Incentives',
                value: CurrencyFormatter.format(detail.activityReward),
                icon: LucideIcons.award,
                accentColor: const Color(0xFFF59E0B),
                customGradient: isDark
                    ? const [Color(0xFF3F1B05), Color(0xFF220E02)]
                    : const [
                        Color(0xFFFFFBEB),
                        Color(0xFFFEF3C7),
                        Color(0xFFFEF08A),
                      ],
                delayMs: 540,
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              DailyMetricTile(
                label: 'Special Bonuses',
                value: CurrencyFormatter.format(detail.otherReward),
                icon: LucideIcons.sparkles,
                accentColor: const Color(0xFF8B5CF6),
                customGradient: isDark
                    ? const [Color(0xFF281050), Color(0xFF160630)]
                    : const [
                        Color(0xFFFAF5FF),
                        Color(0xFFEDE9FE),
                        Color(0xFFF3E8FF),
                      ],
                delayMs: 580,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Buy RP Action Button
        Expanded(
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              context.go('/buy-rp');
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.shoppingBag,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Buy RP Orders',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 620.ms, duration: 400.ms)
            .slideY(
              begin: 0.08,
              end: 0,
              delay: 620.ms,
              curve: Curves.easeOutCubic,
            ),

        const SizedBox(width: 12),

        // Sell RP Action Button
        Expanded(
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              context.go('/sell-rp');
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1A30) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF38BDF8).withValues(alpha: 0.40)
                      : const Color(0xFF0284C7).withValues(alpha: 0.35),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7)
                        .withValues(alpha: isDark ? 0.20 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.repeat,
                    size: 16,
                    color: isDark
                        ? const Color(0xFF38BDF8)
                        : const Color(0xFF0284C7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sell / Withdraw RP',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 660.ms, duration: 400.ms)
            .slideY(
              begin: 0.08,
              end: 0,
              delay: 660.ms,
              curve: Curves.easeOutCubic,
            ),
      ],
    );
  }
}
