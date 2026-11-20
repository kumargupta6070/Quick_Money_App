import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../shared/models/daily_detail_model.dart';
import '../../../core/utils/currency_formatter.dart';
import 'daily_metrics_helper.dart';

class DailyRechargeSection extends StatelessWidget {
  final DailyDetailModel detail;
  final bool isDark;

  const DailyRechargeSection({
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
              ? const [Color(0xFF063A2D), Color(0xFF02261E)]
              : const [Color(0xFFF0FDF4), Color(0xFFDCFCE7), Color(0xFFECFDF5)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xFF10B981).withValues(alpha: 0.40)
              : const Color(0xFF10B981).withValues(alpha: 0.32),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981)
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
            icon: LucideIcons.zap,
            title: 'Recharge Data',
            badge: 'Subordinate Gateway',
            accentColor: const Color(0xFF10B981),
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Subordinate Rebates Header Card
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => HapticFeedback.lightImpact(),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF063B2B), Color(0xFF032218)]
                        : const [
                            Color(0xFFECFDF5),
                            Color(0xFFD1FAE5),
                            Color(0xFFF0FDF4),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF10B981)
                        .withValues(alpha: isDark ? 0.45 : 0.40),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981)
                          .withValues(alpha: isDark ? 0.20 : 0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.flame,
                            size: 16,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Subordinate Rebates',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      CurrencyFormatter.format(detail.subordinateRebates),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 340.ms, duration: 380.ms)
              .slideY(
                begin: 0.12,
                end: 0,
                delay: 340.ms,
                curve: Curves.easeOutBack,
              )
              .scale(
                begin: const Offset(0.92, 0.92),
                end: const Offset(1, 1),
                delay: 340.ms,
                duration: 380.ms,
                curve: Curves.easeOutBack,
              ),

          const SizedBox(height: 10),

          // 3D Crypto Gateway Rows
          DailyCryptoGatewayPill(
            badge: 'USDT',
            badgeColor: const Color(0xFF059669),
            pillGradient: isDark
                ? const [Color(0xFF063B2B), Color(0xFF032218)]
                : const [
                    Color(0xFFF0FDF4),
                    Color(0xFFDCFCE7),
                    Color(0xFFECFDF5),
                  ],
            text: '${detail.usdtRecharge.toStringAsFixed(2)} USDT',
            status: 'TRC-20 Connected',
            delayMs: 380,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          DailyCryptoGatewayPill(
            badge: 'TRX',
            badgeColor: const Color(0xFFDC2626),
            pillGradient: isDark
                ? const [Color(0xFF450A19), Color(0xFF24030D)]
                : const [
                    Color(0xFFFEF2F2),
                    Color(0xFFFEE2E2),
                    Color(0xFFFFF1F2),
                  ],
            text: '${detail.trxRecharge.toStringAsFixed(2)} TRX',
            status: 'Tron Gateway Active',
            delayMs: 420,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}
