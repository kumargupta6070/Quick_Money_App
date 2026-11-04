import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/mock_data/app_mock_data.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../../../shared/widgets/animated_counter.dart';

/// Daily Details Screen - Premium FinTech Animated & Responsive Experience
/// Features 3D colorful buttons, rich background gradients, and staggered entrance animations.
class DailyDetailsScreen extends ConsumerStatefulWidget {
  const DailyDetailsScreen({super.key});

  @override
  ConsumerState<DailyDetailsScreen> createState() => _DailyDetailsScreenState();
}

class _DailyDetailsScreenState extends ConsumerState<DailyDetailsScreen> {
  String _selectedDateFilter = 'Today';
  int _animSeed = 0;

  @override
  Widget build(BuildContext context) {
    final detail = AppMockData.dailyDetail;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Auto-return target calculations (PhonePe target ₹100)
    const targetIncome = 100.0;
    final progress = (detail.totalIncome / targetIncome).clamp(0.0, 1.0);
    final remainingForPhonePe = (targetIncome - detail.totalIncome).clamp(
      0.0,
      targetIncome,
    );

    return Scaffold(
      body: AnimatedAmbientBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            setState(() => _animSeed++);
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: SingleChildScrollView(
            key: ValueKey('daily_scroll_${_animSeed}_$_selectedDateFilter'),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Royal FinTech Curved Hero Header
                _buildHeroHeader(context, isDark)
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: -0.06, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 12),

                // 2. Date Quick Filter Selector Bar
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildDateFilterBar(isDark),
                    )
                    .animate()
                    .fadeIn(delay: 50.ms, duration: 380.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      delay: 50.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 12),

                // 3. Hero Today's Net Revenue 3D Card
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildTodayRevenueHeroCard(
                        detail: detail,
                        progress: progress,
                        remaining: remainingForPhonePe,
                        isDark: isDark,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      delay: 100.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 14),

                // 4. Section: Purchase Data & Trading Metrics (2x2 Grid)
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildPurchaseDataSection(detail, isDark),
                    )
                    .animate()
                    .fadeIn(delay: 160.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      delay: 160.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 14),

                // 5. Section: Recharge Data & Crypto Gateway Logs
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildRechargeDataSection(detail, isDark),
                    )
                    .animate()
                    .fadeIn(delay: 220.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      delay: 220.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 14),

                // 6. Section: Data for Sale & Realized Liquidity
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildDataForSaleSection(detail, isDark),
                    )
                    .animate()
                    .fadeIn(delay: 280.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      delay: 280.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 14),

                // 7. Section: Platform Rewards & Community Bonuses
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildPlatformRewardsSection(detail, isDark),
                    )
                    .animate()
                    .fadeIn(delay: 340.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      delay: 340.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 18),

                // 8. Quick Navigation Trading Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildActionButtons(context, isDark),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Royal FinTech Header with Zero Overflow
  Widget _buildHeroHeader(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF07112E),
                  const Color(0xFF0D256B),
                  const Color(0xFF133694),
                ]
              : [
                  const Color(0xFF091A4B),
                  const Color(0xFF11359A),
                  const Color(0xFF1849D6),
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D256B).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
          child: Row(
            children: [
              // Frosted Back Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: const Icon(
                    LucideIcons.arrowLeft,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Title Column (Expanded to prevent overflow)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Daily Details',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.40),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF34D399),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'AUDITED',
                                style: GoogleFonts.spaceGrotesk(
                                  color: const Color(0xFF6EE7B7),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Real-time revenue, order yield & rebate breakdown',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Live Calendar Icon Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  CustomSnackBar.showInfo(
                    context: context,
                    message:
                        'Audited financial ledger for current fiscal cycle.',
                    icon: LucideIcons.calendar,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: const Icon(
                    LucideIcons.calendarCheck,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Date Quick Filter Bar
  Widget _buildDateFilterBar(bool isDark) {
    const filters = ['Today', 'Yesterday', '7 Days', 'This Month'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1A30) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: filters.map((f) {
          final isSelected = _selectedDateFilter == f;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedDateFilter = f);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0284C7)
                                .withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    f,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11.5,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF475569)),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Hero Today's Net Revenue 3D Card
  Widget _buildTodayRevenueHeroCard({
    required dynamic detail,
    required double progress,
    required double remaining,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF102148),
                  const Color(0xFF0A142E),
                  const Color(0xFF14295A),
                ]
              : [
                  const Color(0xFF0F172A),
                  const Color(0xFF1E293B),
                  const Color(0xFF0F1E3D),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Tag + Live Calendar Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.sparkles,
                      size: 13,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "TODAY'S TOTAL INCOME",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.calendar,
                      size: 11,
                      color: Color(0xFF38BDF8),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      detail.date,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Giant Animated Income Counter
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF38BDF8),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AnimatedCounter(
                    value: detail.totalIncome,
                    decimalDigits: 2,
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.40),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.trendingUp,
                      size: 12,
                      color: Color(0xFF34D399),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+2.5% yield',
                      style: GoogleFonts.spaceGrotesk(
                        color: const Color(0xFF6EE7B7),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // PhonePe Auto-Return Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PhonePe Auto-Return Target: ₹100.00',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF38BDF8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Settlement Note Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF6366F1).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.shieldCheck,
                  size: 13,
                  color: Color(0xFF818CF8),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '₹${remaining.toStringAsFixed(2)} remaining to trigger instant PhonePe auto-credit.',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFC7D2FE),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section 1: Purchase Data (Cyan / Sky FinTech Gradient Card)
  Widget _buildPurchaseDataSection(dynamic detail, bool isDark) {
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
          _buildSectionTitle(
            icon: LucideIcons.shoppingBag,
            title: 'Purchase Data',
            badge: 'Buy RP Orders',
            accentColor: const Color(0xFF0284C7),
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          // 2x2 Metric Grid with individual background colors and animated entrance
          Row(
            children: [
              _buildMetricTile(
                label: 'Order Count',
                value: '${detail.purchaseNumber} Order',
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
              _buildMetricTile(
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
              _buildMetricTile(
                label: 'Brokerage Yield',
                value: '+₹${detail.brokerage.toStringAsFixed(2)}',
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
              _buildMetricTile(
                label: 'Team Rebates',
                value: '₹${detail.teamRebates.toStringAsFixed(2)}',
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

  /// Section 2: Recharge Data (Emerald / Mint FinTech Gradient Card)
  Widget _buildRechargeDataSection(dynamic detail, bool isDark) {
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
          _buildSectionTitle(
            icon: LucideIcons.zap,
            title: 'Recharge Data',
            badge: 'Subordinate Gateway',
            accentColor: const Color(0xFF10B981),
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Subordinate Rebates Header Card (With Mint Gradient Background & Animation)
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
                          '₹${detail.subordinateRebates.toStringAsFixed(2)}',
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

          // 3D Crypto Gateway Rows with Background Colors & Animated Entrance
          _buildCryptoGatewayPill(
            badge: 'USDT',
            badgeColor: const Color(0xFF059669),
            pillGradient: isDark
                ? const [Color(0xFF063B2B), Color(0xFF032218)]
                : const [
                    Color(0xFFF0FDF4),
                    Color(0xFFDCFCE7),
                    Color(0xFFECFDF5),
                  ],
            text: '${detail.usdtRecharge.toStringAsFixed(4)} USDT = ₹0.00',
            status: 'TRC-20 Connected',
            delayMs: 380,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildCryptoGatewayPill(
            badge: 'TRX',
            badgeColor: const Color(0xFFDC2626),
            pillGradient: isDark
                ? const [Color(0xFF450A19), Color(0xFF24030D)]
                : const [
                    Color(0xFFFEF2F2),
                    Color(0xFFFEE2E2),
                    Color(0xFFFFF1F2),
                  ],
            text: '${detail.trxRecharge.toStringAsFixed(4)} TRX = ₹0.00',
            status: 'Tron Gateway Active',
            delayMs: 420,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  /// Section 3: Data for Sale (Rose / Coral FinTech Gradient Card)
  Widget _buildDataForSaleSection(dynamic detail, bool isDark) {
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
          _buildSectionTitle(
            icon: LucideIcons.repeat,
            title: 'Data for Sale',
            badge: 'Sell RP Liquidity',
            accentColor: const Color(0xFFEF4444),
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              _buildMetricTile(
                label: 'Completed Sales',
                value: '${detail.sellNumber} Orders',
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
              _buildMetricTile(
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

  /// Section 4: Platform Rewards (Amber / Gold FinTech Gradient Card)
  Widget _buildPlatformRewardsSection(dynamic detail, bool isDark) {
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
          _buildSectionTitle(
            icon: LucideIcons.gift,
            title: 'Platform Rewards',
            badge: 'Community Pool',
            accentColor: const Color(0xFFF59E0B),
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              _buildMetricTile(
                label: 'Activity Incentives',
                value: '₹${detail.activityReward.toStringAsFixed(2)}',
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
              _buildMetricTile(
                label: 'Special Bonuses',
                value: '₹${detail.otherReward.toStringAsFixed(2)}',
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

  /// Reusable Section Header with Badge
  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String badge,
    required Color accentColor,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: isDark ? 0.25 : 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: accentColor),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isDark ? 0.20 : 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            badge.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Reusable 3D Metric Button/Tile with Background Color & Animated Entrance
  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    required int delayMs,
    List<Color>? customGradient,
    bool isHighlight = false,
    VoidCallback? onTap,
  }) {
    final gradient =
        customGradient ??
        (isDark
            ? [
                accentColor.withValues(alpha: 0.28),
                accentColor.withValues(alpha: 0.14),
              ]
            : [
                accentColor.withValues(alpha: 0.16),
                accentColor.withValues(alpha: 0.08),
                Colors.white,
              ]);

    return Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                if (onTap != null) onTap();
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accentColor.withValues(alpha: isDark ? 0.50 : 0.40),
                    width: isHighlight ? 1.5 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(
                        alpha: isDark ? 0.25 : 0.14,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(icon, size: 13, color: accentColor),
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
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isHighlight
                              ? accentColor
                              : (isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: delayMs.ms, duration: 380.ms)
        .slideY(
          begin: 0.12,
          end: 0,
          delay: delayMs.ms,
          curve: Curves.easeOutBack,
        )
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          delay: delayMs.ms,
          duration: 380.ms,
          curve: Curves.easeOutBack,
        );
  }

  /// Reusable Crypto Gateway Button/Pill with Background Color & Animated Entrance
  Widget _buildCryptoGatewayPill({
    required String badge,
    required Color badgeColor,
    required String text,
    required String status,
    required bool isDark,
    required int delayMs,
    required List<Color> pillGradient,
  }) {
    return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: pillGradient,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: badgeColor.withValues(alpha: isDark ? 0.45 : 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withValues(alpha: isDark ? 0.20 : 0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4.5,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          badgeColor,
                          badgeColor.withValues(alpha: 0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: badgeColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: badgeColor.withValues(alpha: 0.30),
                      ),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : badgeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: delayMs.ms, duration: 380.ms)
        .slideY(
          begin: 0.12,
          end: 0,
          delay: delayMs.ms,
          curve: Curves.easeOutBack,
        )
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          delay: delayMs.ms,
          duration: 380.ms,
          curve: Curves.easeOutBack,
        );
  }

  /// Quick Trading Action Buttons
  Widget _buildActionButtons(BuildContext context, bool isDark) {
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
