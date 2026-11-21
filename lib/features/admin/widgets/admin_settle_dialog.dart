import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';

class AdminSettleDialog extends ConsumerStatefulWidget {
  final AdminPayoutItem payout;
  final bool isDark;

  const AdminSettleDialog({
    super.key,
    required this.payout,
    required this.isDark,
  });

  @override
  ConsumerState<AdminSettleDialog> createState() => _AdminSettleDialogState();
}

class _AdminSettleDialogState extends ConsumerState<AdminSettleDialog> {
  final _utrController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _utrController.dispose();
    super.dispose();
  }

  void _generateMockUtr() {
    HapticFeedback.lightImpact();
    final randomUtr = 'PP${DateTime.now().millisecondsSinceEpoch.toString().substring(3)}';
    _utrController.text = randomUtr;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final utr = _utrController.text.trim();
    Navigator.pop(context);

    CustomLoader.show(context, message: 'Settling payout with NPCI/Bank Gateway...');
    final ok = await ref.read(adminProvider.notifier).settlePayout(
          widget.payout.id,
          utr,
        );

    if (mounted) {
      CustomLoader.hide(context);
      if (ok) {
        HapticFeedback.mediumImpact();
        CustomSnackBar.showTopSuccess(
          context: context,
          message:
              'Payout of ${CurrencyFormatter.format(widget.payout.amount)} settled with UTR $utr',
          icon: LucideIcons.checkCheck,
        );
      } else {
        CustomSnackBar.showTopError(
          context: context,
          message: 'Failed to settle payout. Please check connection.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final payout = widget.payout;
    const themeColor = Color(0xFF10B981);

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: themeColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.banknote,
              color: themeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settle PhonePe Return',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'User: ${payout.userEmail}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount and Destination Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Disbursement Amount:',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(payout.amount),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Target PhonePe UPI:',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        payout.destinationUpi,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF38BDF8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Bank UTR Field
            TextFormField(
              controller: _utrController,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                labelText: 'Bank UTR / Transaction Reference',
                hintText: 'e.g. PP9876543210',
                prefixIcon: const Icon(LucideIcons.fileCheck, size: 16),
                suffixIcon: IconButton(
                  icon: const Icon(LucideIcons.sparkles, size: 16, color: Color(0xFFF59E0B)),
                  tooltip: 'Auto-Generate UTR',
                  onPressed: _generateMockUtr,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: themeColor, width: 1.5),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().length < 6) {
                  return 'Please enter valid Bank UTR (minimum 6 characters)';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Confirm Settlement',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ).animate().scale(begin: const Offset(0.92, 0.92), duration: 220.ms).fade();
  }
}
