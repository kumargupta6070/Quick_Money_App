import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/models/transaction_model.dart';
import 'transaction_receipt_sheet.dart';

/// Vivid Animated Transaction Card
class TransactionCard extends StatelessWidget {
  final TransactionModel tx;
  final int index;
  final bool isDark;

  const TransactionCard({
    super.key,
    required this.tx,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
      onTap: () => TransactionReceiptSheet.show(context, tx),
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
                              color: const Color(0xFF5F259F).withValues(alpha: 0.15),
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
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
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
}
