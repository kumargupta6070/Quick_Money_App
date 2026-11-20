import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/models/transaction_model.dart';
import 'transaction_receipt_breakdown_card.dart';

/// Modal bottom sheet displaying detailed transaction receipt with copyable IDs,
/// glowing animated badges, and direct PhonePe settlement breakdown.
class TransactionReceiptSheet extends StatefulWidget {
  final TransactionModel tx;
  final bool isDark;

  const TransactionReceiptSheet({
    super.key,
    required this.tx,
    required this.isDark,
  });

  static Future<void> show(BuildContext context, TransactionModel tx) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TransactionReceiptSheet(tx: tx, isDark: isDark),
    );
  }

  @override
  State<TransactionReceiptSheet> createState() => _TransactionReceiptSheetState();
}

class _TransactionReceiptSheetState extends State<TransactionReceiptSheet> {
  String? _inModalNotice;

  void _triggerCopy(String textToCopy, String noticeMessage) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: textToCopy));
    setState(() {
      _inModalNotice = noticeMessage;
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && _inModalNotice == noticeMessage) {
        setState(() {
          _inModalNotice = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.tx;
    final isDark = widget.isDark;
    final isPayout = tx.type == TransactionType.payout;
    final accentColor = isPayout
        ? const Color(0xFF10B981)
        : (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7));

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

            if (_inModalNotice != null) ...[
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
                          color: const Color(0xFF10B981).withValues(alpha: 0.35),
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
                          _inModalNotice!,
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
                  isPayout ? LucideIcons.checkCheck : LucideIcons.arrowUpRight,
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
                    isPayout ? 'PHONEPE 100% SETTLED' : 'CONFIRMED DEPOSIT',
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

            // Formatted Amount
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
            TransactionReceiptBreakdownCard(
              tx: tx,
              isDark: isDark,
              accentColor: accentColor,
              onCopy: _triggerCopy,
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
                      _triggerCopy(
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                            color: accentColor.withValues(alpha: 0.35),
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
  }
}
