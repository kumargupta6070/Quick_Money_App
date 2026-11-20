import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../shared/models/daily_detail_model.dart';
import '../../../core/utils/currency_formatter.dart';
import 'daily_metrics_helper.dart';

class DailyPurchaseSection extends StatelessWidget {
  final DailyDetailModel detail;
  final bool isDark;

  const DailyPurchaseSection({
    super.key,
    required this.detail,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF0F1E3D), Color(0xFF0A152E)]
              : const [Color(0xFFEFF8FF), Color(0xFFE0F2FE), Color(0xFFF0FDF4)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xFF38BDF8).withValues(alpha: 0.35)
              : const Color(0xFF0284C7).withValues(alpha: 0.28),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7)
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
            icon: LucideIcons.shoppingBag,
            title: 'Purchase Data',
            badge: 'Buy RP Orders',
            accentColor: const Color(0xFF0284C7),
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          // 2x2 Metric Grid
          Row(
            children: [
              DailyMetricTile(
                label: 'Order Count',
                value: detail.purchaseNumber == 1
                    ? '1 Order'
                    : '${detail.purchaseNumber} Orders',
                icon: LucideIcons.receipt,
                accentColor: const Color(0xFF0284C7),
                customGradient: isDark
                    ? const [Color(0xFF0C2448), Color(0xFF081830)]
                    : const [
                        Color(0xFFE0F2FE),
                        Color(0xFFBAE6FD),
                        Color(0xFFF0F9FF),
                      ],
                delayMs: 180,
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              DailyMetricTile(
                label: 'Committed Funds',
                value: CurrencyFormatter.format(detail.purchaseAmount),
                icon: LucideIcons.wallet,
                accentColor: const Color(0xFF2563EB),
                customGradient: isDark
                    ? const [Color(0xFF0F204C), Color(0xFF081330)]
                    : const [
                        Color(0xFFEFF6FF),
                        Color(0xFFDBEAFE),
                        Color(0xFFE0E7FF),
                      ],
                delayMs: 220,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              DailyMetricTile(
                label: 'Brokerage Yield',
                value: detail.brokerage > 0
                    ? '+${CurrencyFormatter.format(detail.brokerage)}'
                    : CurrencyFormatter.format(detail.brokerage),
                icon: LucideIcons.trendingUp,
                accentColor: const Color(0xFF10B981),
                customGradient: isDark
                    ? const [Color(0xFF063B2B), Color(0xFF032218)]
                    : const [
                        Color(0xFFECFDF5),
                        Color(0xFFD1FAE5),
                        Color(0xFFDCFCE7),
                      ],
                isHighlight: true,
                delayMs: 260,
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              DailyMetricTile(
                label: 'Team Rebates',
                value: CurrencyFormatter.format(detail.teamRebates),
                icon: LucideIcons.users,
                accentColor: const Color(0xFF8B5CF6),
                customGradient: isDark
                    ? const [Color(0xFF281050), Color(0xFF160630)]
                    : const [
                        Color(0xFFFAF5FF),
                        Color(0xFFEDE9FE),
                        Color(0xFFF3E8FF),
                      ],
                delayMs: 300,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
