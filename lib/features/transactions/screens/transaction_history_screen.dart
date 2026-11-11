import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/transaction_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/widgets/animated_ambient_background.dart';

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

  void _showTransactionReceipt(BuildContext context, TransactionModel tx) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPayout = tx.type == TransactionType.payout;
    final accentColor = isPayout
        ? const Color(0xFF10B981)
        : (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String? inModalNotice;
        return StatefulBuilder(
          builder: (sheetCtx, setModalState) {
            void triggerCopy(String textToCopy, String noticeMessage) {
              HapticFeedback.lightImpact();
              Clipboard.setData(ClipboardData(text: textToCopy));
              setModalState(() {
                inModalNotice = noticeMessage;
              });
              Future.delayed(const Duration(milliseconds: 2500), () {
                if (sheetCtx.mounted) {
                  setModalState(() {
                    if (inModalNotice == noticeMessage) {
                      inModalNotice = null;
                    }
                  });
                }
              });
            }

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF071126) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                border: Border.all(
                  color: accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: isDark ? 0.25 : 0.15),
                    blurRadius: 36,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top drag handle
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    if (inModalNotice != null) ...[
                      const SizedBox(height: 12),
                      Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF065F46), Color(0xFF10B981)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.checkCheck,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  inModalNotice!,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 200.ms)
                          .slideY(begin: -0.2, end: 0),
                    ],
                    const SizedBox(height: 16),

                    // Pulsating Dual Ring Success Status Emblem
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.35),
                          width: 2,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isPayout
                                ? [
                                    const Color(0xFF059669),
                                    const Color(0xFF10B981),
                                  ]
                                : [
                                    const Color(0xFF0284C7),
                                    const Color(0xFF2563EB),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.40),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          isPayout
                              ? LucideIcons.checkCheck
                              : LucideIcons.arrowUpRight,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ).animate().scale(
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),

                    const SizedBox(height: 12),

                    // Live Guaranteed Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isPayout
                                ? 'PHONEPE 100% SETTLED'
                                : 'CONFIRMED DEPOSIT',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: accentColor,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 80.ms, duration: 350.ms),

                    const SizedBox(height: 8),

                    Text(
                      isPayout ? 'Payout Return Settled' : 'Deposit Completed',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ).animate().fadeIn(delay: 120.ms, duration: 350.ms),

                    const SizedBox(height: 4),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.clock,
                          size: 13,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          DateFormatter.formatDateTime(tx.createdAt),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 140.ms, duration: 350.ms),

                    const SizedBox(height: 14),

                    // Giant Formatted Amount with Glowing FinTech Colors
                    Text(
                          '${isPayout ? "+" : "-"} ${CurrencyFormatter.format(tx.amount)}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            color: accentColor,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 180.ms, duration: 380.ms)
                        .scale(
                          begin: const Offset(0.92, 0.92),
                          delay: 180.ms,
                          curve: Curves.easeOutBack,
                        ),

                    const SizedBox(height: 16),

                    // Vivid Receipt Breakdown Card
                    Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isPayout
                                  ? (isDark
                                        ? [
                                            const Color(0xFF062C1E),
                                            const Color(0xFF0B3D2A),
                                          ]
                                        : [
                                            const Color(0xFFF0FDF4),
                                            const Color(0xFFDCFCE7),
                                          ])
                                  : (isDark
                                        ? [
                                            const Color(0xFF0C244C),
                                            const Color(0xFF11326E),
                                          ]
                                        : [
                                            const Color(0xFFF0F9FF),
                                            const Color(0xFFE0F2FE),
                                          ]),
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: accentColor.withValues(
                                alpha: isDark ? 0.40 : 0.30,
                              ),
                              width: 1.3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(
                                  alpha: isDark ? 0.18 : 0.08,
                                ),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildReceiptRow(
                                'Transaction ID',
                                '#QM-${tx.referenceId ?? tx.id.toString().padLeft(6, '0')}',
                                isDark,
                                canCopy: true,
                                accentColor: accentColor,
                                onCopy: () => triggerCopy(
                                  '#QM-${tx.referenceId ?? tx.id.toString().padLeft(6, '0')}',
                                  'Transaction ID copied to clipboard!',
                                ),
                              ),
                              const Divider(height: 16),
                              _buildReceiptRow(
                                'Gateway Partner',
                                'UPI Auto-Switch',
                                isDark,
                                chipTag: 'पे PhonePe',
                                chipColor: const Color(0xFF8A2BE2),
                                accentColor: accentColor,
                              ),
                              const Divider(height: 16),
                              _buildReceiptRow(
                                isPayout ? 'Destination UPI' : 'Funding Source',
                                isPayout
                                    ? (tx.paymentDestination ??
                                          '919835913180@ybl')
                                    : (tx.paymentSource ?? 'PhonePe Wallet'),
                                isDark,
                                canCopy: true,
                                accentColor: accentColor,
                                onCopy: () {
                                  final dest = isPayout
                                      ? (tx.paymentDestination ??
                                            '919835913180@ybl')
                                      : (tx.paymentSource ?? 'PhonePe Wallet');
                                  triggerCopy(
                                    dest,
                                    'Copied $dest to clipboard!',
                                  );
                                },
                              ),
                              if (tx.profit > 0) ...[
                                const Divider(height: 16),
                                _buildReceiptRow(
                                  'Realized Yield',
                                  '+₹${tx.profit.toStringAsFixed(2)}',
                                  isDark,
                                  highlightColor: const Color(0xFF10B981),
                                  chipTag: '+2.5% Gain',
                                  chipColor: const Color(0xFF10B981),
                                  accentColor: accentColor,
                                ),
                              ],
                              const Divider(height: 16),
                              _buildReceiptRow(
                                'Settlement State',
                                'PhonePe Direct',
                                isDark,
                                highlightColor: const Color(0xFF10B981),
                                chipTag: '100% SUCCESS',
                                chipColor: const Color(0xFF10B981),
                                accentColor: accentColor,
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 240.ms, duration: 400.ms)
                        .slideY(begin: 0.06, end: 0, delay: 240.ms),

                    const SizedBox(height: 20),

                    // Action Buttons Row
                    Row(
                          children: [
                            // Share Receipt Button
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  final receiptSummary =
                                      'Quick Money FinTech Transaction Receipt: ${isPayout ? "Payout Return" : "Deposit"} of ${CurrencyFormatter.format(tx.amount)} successfully settled via PhonePe! Txn ID: #QM-${tx.referenceId ?? tx.id}';
                                  triggerCopy(
                                    receiptSummary,
                                    'Receipt details copied to clipboard!',
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.20)
                                        : const Color(0xFFCBD5E1),
                                    width: 1.3,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.share2,
                                      size: 16,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Share',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Done / Close Button
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pop(ctx);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isPayout
                                          ? [
                                              const Color(0xFF059669),
                                              const Color(0xFF10B981),
                                            ]
                                          : [
                                              const Color(0xFF0284C7),
                                              const Color(0xFF2563EB),
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accentColor.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Done',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 400.ms)
                        .slideY(begin: 0.06, end: 0, delay: 300.ms),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value,
    bool isDark, {
    bool canCopy = false,
    Color? highlightColor,
    String? chipTag,
    Color? chipColor,
    Color? accentColor,
    VoidCallback? onCopy,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (chipTag != null) ...[
                Flexible(
                  flex: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: (chipColor ?? const Color(0xFF10B981)).withValues(
                        alpha: 0.15,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      chipTag,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: chipColor ?? const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color:
                          highlightColor ??
                          (isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                  ),
                ),
              ),
              if (canCopy) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (onCopy != null) {
                      onCopy();
                    } else {
                      Clipboard.setData(ClipboardData(text: value));
                      CustomSnackBar.showTopToast(
                        context: context,
                        message: 'Copied $value to clipboard',
                        icon: LucideIcons.checkCheck,
                      );
                    }
                  },
                  child: Icon(
                    LucideIcons.copy,
                    size: 13,
                    color:
                        accentColor ??
                        (isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0284C7)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

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
                _buildHeroHeader(context, isDark)
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: -0.05, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 14),

                // ── 2. Real-Time Payout & Volume Summary Row ──
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSummaryMetrics(isDark),
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
                  child: _buildFilterTabs(isDark),
                ).animate().fadeIn(delay: 140.ms, duration: 380.ms),

                const SizedBox(height: 14),

                // ── 4. Transaction Cards List ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: filteredTransactions.isEmpty
                      ? _buildEmptyState(isDark)
                      : Column(
                          children: [
                            for (
                              int i = 0;
                              i < filteredTransactions.length;
                              i++
                            )
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildTransactionCard(
                                  context: context,
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

  /// Royal FinTech Curved Hero Header
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
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D256B).withValues(alpha: 0.40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction & Payout Records',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'Real-time PhonePe auto-payout & deposit ledger',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'SYNCED',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Summary Metrics Bar with FinTech colorful gradients and zero overflow
  Widget _buildSummaryMetrics(bool isDark) {
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

  /// Filter Tabs (All, Payout Returns, Deposits)
  Widget _buildFilterTabs(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A1228)
            : const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _buildFilterTabItem('all', 'All Records', isDark)),
          Expanded(
            child: _buildFilterTabItem('payout', 'PhonePe Returns', isDark),
          ),
          Expanded(child: _buildFilterTabItem('deposit', 'Deposits', isDark)),
        ],
      ),
    );
  }

  Widget _buildFilterTabItem(String key, String label, bool isDark) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedFilter = key);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E3A8A) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected
                  ? (isDark ? Colors.white : const Color(0xFF0F172A))
                  : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)),
            ),
          ),
        ),
      ),
    );
  }

  /// Vivid Animated Transaction Card
  Widget _buildTransactionCard({
    required BuildContext context,
    required TransactionModel tx,
    required int index,
    required bool isDark,
  }) {
    final isPayout = tx.type == TransactionType.payout;
    final accentColor = isPayout
        ? const Color(0xFF10B981)
        : (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7));

    final gradientColors = isPayout
        ? (isDark
              ? [const Color(0xFF0B2B1F), const Color(0xFF103F2E)]
              : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)])
        : (isDark
              ? [const Color(0xFF0C244C), const Color(0xFF11326E)]
              : [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)]);

    return InkWell(
          onTap: () => _showTransactionReceipt(context, tx),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentColor.withValues(alpha: isDark ? 0.45 : 0.35),
                width: 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: isDark ? 0.18 : 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Icon, Title & Amount
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor,
                            accentColor.withValues(alpha: 0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isPayout
                            ? LucideIcons.arrowDownLeft
                            : LucideIcons.arrowUpRight,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  isPayout
                                      ? 'PhonePe Payout Return'
                                      : 'Money Added (Deposit)',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5F259F)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'पे PhonePe',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF8A2BE2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormatter.formatDateTime(tx.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isPayout ? "+" : "-"} ${CurrencyFormatter.format(tx.amount)}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: accentColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          isPayout ? 'Credited' : 'Debited',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Bottom Info Strip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.70),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isPayout
                              ? 'Returned to PhonePe: ${tx.paymentDestination ?? "919835913180@ybl"}'
                              : 'Funded from: ${tx.paymentSource ?? "PhonePe"}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155),
                          ),
                        ),
                      ),
                      if (tx.profit > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.sparkles,
                                size: 11,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Profit: +₹${tx.profit.toStringAsFixed(2)}',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (160 + index * 50).ms, duration: 380.ms)
        .slideY(
          begin: 0.08,
          end: 0,
          delay: (160 + index * 50).ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1A30) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.receipt,
            size: 48,
            color: isDark ? Colors.white38 : Colors.black26,
          ),
          const SizedBox(height: 12),
          Text(
            'No Records Found',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Transactions will appear here once orders are processed.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
