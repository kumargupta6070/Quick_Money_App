import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_money/core/providers/profit_provider.dart';
import 'package:quick_money/features/daily_details/widgets/daily_date_filter_bar.dart';
import 'package:quick_money/features/daily_details/widgets/daily_details_hero_header.dart';
import 'package:quick_money/features/daily_details/widgets/daily_purchase_section.dart';
import 'package:quick_money/features/daily_details/widgets/daily_recharge_section.dart';
import 'package:quick_money/features/daily_details/widgets/daily_revenue_hero_card.dart';
import 'package:quick_money/features/daily_details/widgets/daily_sale_and_rewards_section.dart';
import 'package:quick_money/shared/widgets/animated_ambient_background.dart';

class DailyDetailsScreen extends ConsumerStatefulWidget {
  const DailyDetailsScreen({super.key});

  @override
  ConsumerState<DailyDetailsScreen> createState() => _DailyDetailsScreenState();
}

class _DailyDetailsScreenState extends ConsumerState<DailyDetailsScreen> {
  String _selectedDateFilter = 'Today';
  int _animSeed = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchForFilter('Today'));
  }

  Future<void> _fetchForFilter(String filter) async {
    await ref.read(profitProvider.notifier).fetchDailyDetails(filter: filter);
    if (mounted) setState(() {});
  }

  Future<void> _fetchForDate(String date) async {
    await ref.read(profitProvider.notifier).fetchDailyDetails(date: date);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(profitProvider);
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
            if (_selectedDateFilter.contains('-')) {
              await _fetchForDate(_selectedDateFilter);
            } else {
              await _fetchForFilter(_selectedDateFilter);
            }
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
                DailyDetailsHeroHeader(
                  isDark: isDark,
                  onDateSelected: (dateStr) async {
                    setState(() => _selectedDateFilter = dateStr);
                    await _fetchForDate(dateStr);
                  },
                )
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: -0.06, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 12),

                // 2. Date Quick Filter Selector Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DailyDateFilterBar(
                    isDark: isDark,
                    selectedFilter: _selectedDateFilter,
                    onFilterSelected: (filter) {
                      setState(() => _selectedDateFilter = filter);
                      _fetchForFilter(filter);
                    },
                  ),
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
                  child: DailyRevenueHeroCard(
                    detail: detail,
                    progress: progress,
                    remaining: remainingForPhonePe,
                    selectedDateFilter: _selectedDateFilter,
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
                  child: DailyPurchaseSection(detail: detail, isDark: isDark),
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
                  child: DailyRechargeSection(detail: detail, isDark: isDark),
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

                // 6, 7 & 8: Data for Sale, Platform Rewards, and Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DailySaleAndRewardsSection(
                    detail: detail,
                    isDark: isDark,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 280.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      delay: 280.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
