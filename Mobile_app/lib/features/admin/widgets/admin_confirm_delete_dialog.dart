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

/// High-Security Double-Confirmation Dialog for Permanent User Deletion.
class AdminConfirmDeleteDialog extends ConsumerWidget {
  final int userId;
  final String email;
  final double balance;
  final bool isDark;

  const AdminConfirmDeleteDialog({
    super.key,
    required this.userId,
    required this.email,
    required this.balance,
    required this.isDark,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int userId,
    required String email,
    required double balance,
    required bool isDark,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AdminConfirmDeleteDialog(
        userId: userId,
        email: email,
        balance: balance,
        isDark: isDark,
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    HapticFeedback.heavyImpact();
    CustomLoader.show(context, message: 'Wiping user record and cascading assets...');

    bool success = false;
    try {
      success =
          await ref.read(adminProvider.notifier).deleteUserPermanently(userId);
    } catch (_) {
      success = false;
    } finally {
      CustomLoader.hide(context);
    }

    if (!context.mounted) return;

    if (success) {
      Navigator.pop(context, true);
      CustomSnackBar.showTopSuccess(
        context: context,
        message: 'User $email deleted permanently.',
        icon: LucideIcons.trash2,
      );
    } else {
      CustomSnackBar.showTopError(
        context: context,
        message: 'Failed to delete user. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const dangerColor = Color(0xFFEF4444);

    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      content: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF241216), Color(0xFF14080B)]
                : const [Colors.white, Color(0xFFFFF1F2)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: dangerColor.withValues(alpha: 0.45), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: dangerColor.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
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
                      colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: dangerColor.withValues(alpha: 0.45),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(LucideIcons.alertOctagon, color: Colors.white, size: 22),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.1, 1.1), duration: const Duration(milliseconds: 900)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Permanent Deletion',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: dangerColor.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User: $email',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vault Balance: ${CurrencyFormatter.format(balance)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: dangerColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '⚠️ CRITICAL: This action cannot be reversed. All orders, bound PhonePe wallets, referral links, and transactions will be permanently purged.',
              style: GoogleFonts.inter(
                fontSize: 12,
                height: 1.4,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: dangerColor.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _handleDelete(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Purge Permanently',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12.5,
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
    ).animate().scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack, duration: 250.ms).fade();
  }
}
