import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/mock_data/app_mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/animated_counter.dart';

/// Daily Details Screen directly matching Screenshots 2 & 3.
/// Shows daily income breakdown, purchase data, recharge data, sale data, and platform rewards.
class DailyDetailsScreen extends StatelessWidget {
  const DailyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final detail = AppMockData.dailyDetail;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Daily details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Dark Banner: Today's total income (From Screenshot 2)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161F30) : const Color(0xFF111827),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's total income:",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        detail.date,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AnimatedCounter(
                    value: detail.totalIncome,
                    decimalDigits: 2,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fade(duration: 400.ms)
                .slideY(begin: -0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

            const SizedBox(height: 12),

            // Section 1: Purchase Data
            _buildSectionHeader('Purchase data'),
            _buildCard(
              context: context,
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildGridCell(context, 'Number', '${detail.purchaseNumber}'),
                      _buildVerticalDivider(context),
                      _buildGridCell(context, 'Amount', '${detail.purchaseAmount}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildGridCell(context, 'Brokerage', '${detail.brokerage}', isHighlight: true),
                      _buildVerticalDivider(context),
                      _buildGridCell(context, 'Team Rebates', '${detail.teamRebates}'),
                    ],
                  ),
                ],
              ),
              delayMs: 100,
            ),

            const SizedBox(height: 12),

            // Section 2: Recharge Data
            _buildSectionHeader('Recharge data'),
            _buildCard(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subordinate Rebates: ${detail.subordinateRebates}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildCryptoRow(
                    badge: 'USDT',
                    text: '${detail.usdtRecharge.toStringAsFixed(4)} USDT = 0.0',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildCryptoRow(
                    badge: 'TRX',
                    text: '${detail.trxRecharge.toStringAsFixed(4)} TRX = 0.0',
                    isDark: isDark,
                  ),
                ],
              ),
              delayMs: 200,
            ),

            const SizedBox(height: 12),

            // Section 3: Data for Sale
            _buildSectionHeader('Data for sale'),
            _buildCard(
              context: context,
              child: Row(
                children: [
                  _buildGridCell(context, 'Number', '${detail.sellNumber}'),
                  _buildVerticalDivider(context),
                  _buildGridCell(context, 'Amount', '${detail.sellAmount}', isHighlight: true),
                ],
              ),
              delayMs: 300,
            ),

            const SizedBox(height: 12),

            // Section 4: Platform Rewards
            _buildSectionHeader('Platform Rewards'),
            _buildCard(
              context: context,
              child: Row(
                children: [
                  _buildGridCell(context, 'Activity', '${detail.activityReward}'),
                  _buildVerticalDivider(context),
                  _buildGridCell(context, 'Other', '${detail.otherReward}'),
                ],
              ),
              delayMs: 400,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required Widget child,
    required int delayMs,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1,
        ),
        boxShadow: AppSpacing.cardShadow(context),
      ),
      child: child,
    )
        .animate()
        .fade(delay: delayMs.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0, delay: delayMs.ms, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildGridCell(BuildContext context, String label, String value, {bool isHighlight = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isHighlight
                  ? AppColors.brandPrimary
                  : (isDark ? AppColors.darkText : AppColors.lightText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 1,
      height: 36,
      color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
    );
  }

  Widget _buildCryptoRow({required String badge, required String text, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

