import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/transaction_provider.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../widgets/transaction_card.dart';
import '../widgets/transaction_empty_state.dart';
import '../widgets/transaction_filter_bar.dart';
import '../widgets/transaction_hero_header.dart';
import '../widgets/transaction_summary_metrics.dart';

/// Next-Level FinTech Transaction & Payout Records Screen
/// Designed adhering to the ICU Mobile App aesthetic with animated entrance,
/// royal curved hero header, filter tabs, colorful glowing receipt cards,
/// and interactive detail modals.
class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  int _animSeed = 0;
  String _selectedFilter = 'all'; // 'all', 'payout', 'deposit'

  @override
  Widget build(BuildContext context) {
    final allTransactions = ref.watch(transactionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredTransactions = allTransactions.where((tx) {
      if (_selectedFilter == 'payout') {
        return tx.type == TransactionType.payout;
      } else if (_selectedFilter == 'deposit') {
        return tx.type != TransactionType.payout;
      }
      return true;
    }).toList();

    return Scaffold(
      body: AnimatedAmbientBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            setState(() => _animSeed++);
            await ref.read(transactionProvider.notifier).fetchTransactions();
          },
          child: SingleChildScrollView(
            key: ValueKey('tx_scroll_${_animSeed}_$_selectedFilter'),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. Royal FinTech Hero Curved Header ──
                TransactionHeroHeader(isDark: isDark)
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: -0.05, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 14),

                // ── 2. Real-Time Payout & Volume Summary Row ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TransactionSummaryMetrics(isDark: isDark),
                )
                    .animate()
                    .fadeIn(delay: 80.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      delay: 80.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 16),

                // ── 3. Filter Pill Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TransactionFilterBar(
                    selectedFilter: _selectedFilter,
                    onFilterChanged: (newFilter) {
                      setState(() => _selectedFilter = newFilter);
                    },
                    isDark: isDark,
                  ),
                ).animate().fadeIn(delay: 140.ms, duration: 380.ms),

                const SizedBox(height: 14),

                // ── 4. Transaction Cards List ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: filteredTransactions.isEmpty
                      ? TransactionEmptyState(isDark: isDark)
                      : Column(
                          children: [
                            for (
                              int i = 0;
                              i < filteredTransactions.length;
                              i++
                            )
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: TransactionCard(
                                  tx: filteredTransactions[i],
                                  index: i,
                                  isDark: isDark,
                                ),
                              ),
                          ],
                        ),
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
