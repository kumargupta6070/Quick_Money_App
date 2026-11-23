import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';
import 'admin_settle_dialog.dart';

class AdminPayoutCard extends ConsumerWidget {
  final AdminPayoutItem payout;
  final bool isDark;

  const AdminPayoutCard({
    super.key,
    required this.payout,
    required this.isDark,
  });

  String _formatMaskedUpi(String upi) {
    final trimmed = upi.trim();
    if (trimmed.isEmpty) return '98*****@ibl';
    final parts = trimmed.split('@');
    if (parts.length == 2) {
      final prefix = parts[0];
      final handle = parts[1];
      if (prefix.length <= 3) return '$prefix*****@$handle';
      return '${prefix.substring(0, 3)}*****@$handle';
    }
    if (trimmed.length <= 4) return '$trimmed*****';
    return '${trimmed.substring(0, 4)}*****';
  }

  void _confirmReject(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        content: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF1E1B2E), Color(0xFF161324)]
                  : const [Color(0xFFFFFFFF), Color(0xFFFFF5F5)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Icon(LucideIcons.shieldAlert, color: Colors.white, size: 22),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reject Payout',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Refunds back to user wallet',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFEE2E2).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User: ${payout.userEmail}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Amount: ${CurrencyFormatter.format(payout.amount)}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Are you sure you want to reject this PhonePe payout? The funds will be credited back to the trader immediately.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Cancel', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          CustomLoader.show(context, message: 'Rejecting payout & refunding wallet...');
                          bool ok = false;
                          try {
                            ok = await ref.read(adminProvider.notifier).rejectPayout(payout.id);
                          } catch (_) {
                            ok = false;
                          } finally {
                            if (context.mounted) CustomLoader.hide(context);
                          }
                          if (context.mounted) {
                            if (ok) {
                              CustomSnackBar.showTopWarning(
                                context: context,
                                message: 'Payout rejected. Amount refunded to user wallet.',
                              );
                            } else {
                              CustomSnackBar.showTopError(
                                context: context,
                                message: 'Failed to reject payout.',
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          'Reject & Refund',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack, duration: 250.ms).fade(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maskedUpi = _formatMaskedUpi(payout.destinationUpi);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1E293B), Color(0xFF192231)]
              : const [Colors.white, Color(0xFFFFFDF5)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.15 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: PhonePe branding + Amount (Zero overflow on all screens)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5F259F),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5F259F).withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'पे',
                          style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'PhonePe Return',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5F259F).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  'NPCI',
                                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF8B5CF6)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            maskedUpi,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  CurrencyFormatter.format(payout.amount),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Details row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'User ID: #${payout.userId}',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  payout.requestedAt.isNotEmpty
                      ? payout.requestedAt.split('T').first
                      : 'Today',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Actions: Settle with Bank UTR + Reject with distinct backgrounds
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AdminSettleDialog(
                          payout: payout,
                          isDark: isDark,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.zap, size: 15, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            'Settle Payout',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.20 : 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.45 : 0.35),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _confirmReject(context, ref),
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.xCircle, size: 14, color: Color(0xFFEF4444)),
                          const SizedBox(width: 5),
                          Text(
                            'Reject',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
