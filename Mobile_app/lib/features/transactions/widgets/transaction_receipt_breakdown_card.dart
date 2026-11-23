import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/models/transaction_model.dart';

/// Vivid Breakdown Card inside the Transaction Receipt Sheet
class TransactionReceiptBreakdownCard extends StatelessWidget {
  final TransactionModel tx;
  final bool isDark;
  final Color accentColor;
  final void Function(String textToCopy, String noticeMessage) onCopy;

  const TransactionReceiptBreakdownCard({
    super.key,
    required this.tx,
    required this.isDark,
    required this.accentColor,
    required this.onCopy,
  });

  Widget _buildReceiptRow(
    BuildContext context,
    String label,
    String value,
    bool isDark, {
    bool canCopy = false,
    Color? highlightColor,
    String? chipTag,
    Color? chipColor,
    Color? accentColor,
    VoidCallback? onCustomCopy,
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
                    if (onCustomCopy != null) {
                      onCustomCopy();
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
    final isPayout = tx.type == TransactionType.payout;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPayout
              ? (isDark
                    ? [const Color(0xFF062C1E), const Color(0xFF0B3D2A)]
                    : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)])
              : (isDark
                    ? [const Color(0xFF0C244C), const Color(0xFF11326E)]
                    : [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)]),
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
            context,
            'Transaction ID',
            '#QM-${tx.referenceId ?? tx.id.toString().padLeft(6, '0')}',
            isDark,
            canCopy: true,
            accentColor: accentColor,
            onCustomCopy: () => onCopy(
              '#QM-${tx.referenceId ?? tx.id.toString().padLeft(6, '0')}',
              'Transaction ID copied to clipboard!',
            ),
          ),
          const Divider(height: 16),
          _buildReceiptRow(
            context,
            'Gateway Partner',
            'UPI Auto-Switch',
            isDark,
            chipTag: 'पे PhonePe',
            chipColor: const Color(0xFF8A2BE2),
            accentColor: accentColor,
          ),
          const Divider(height: 16),
          _buildReceiptRow(
            context,
            isPayout ? 'Destination UPI' : 'Funding Source',
            isPayout
                ? (tx.paymentDestination ?? '919835913180@ybl')
                : (tx.paymentSource ?? 'PhonePe Wallet'),
            isDark,
            canCopy: true,
            accentColor: accentColor,
            onCustomCopy: () {
              final dest = isPayout
                  ? (tx.paymentDestination ?? '919835913180@ybl')
                  : (tx.paymentSource ?? 'PhonePe Wallet');
              onCopy(dest, 'Copied $dest to clipboard!');
            },
          ),
          if (tx.profit > 0) ...[
            const Divider(height: 16),
            _buildReceiptRow(
              context,
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
            context,
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
    );
  }
}
