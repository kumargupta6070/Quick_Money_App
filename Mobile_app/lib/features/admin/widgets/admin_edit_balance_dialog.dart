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

class AdminEditBalanceDialog extends ConsumerStatefulWidget {
  final AdminUserItem user;
  final bool isDark;

  const AdminEditBalanceDialog({
    super.key,
    required this.user,
    required this.isDark,
  });

  static Future<void> show(
    BuildContext context, {
    required AdminUserItem user,
    required bool isDark,
  }) {
    return showDialog(
      context: context,
      builder: (_) => AdminEditBalanceDialog(user: user, isDark: isDark),
    );
  }

  @override
  ConsumerState<AdminEditBalanceDialog> createState() =>
      _AdminEditBalanceDialogState();
}

class _AdminEditBalanceDialogState extends ConsumerState<AdminEditBalanceDialog> {
  final _amountCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isCredit = true;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _confirmAndSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final entered = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    if (entered <= 0) return;

    final delta = _isCredit ? entered : -entered;
    final newBalance = widget.user.balance + delta;
    final themeColor = _isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        content: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDark
                ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
                : const [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: themeColor.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: themeColor.withValues(alpha: 0.25),
                blurRadius: 25,
                offset: const Offset(0, 8),
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
                      gradient: LinearGradient(
                        colors: _isCredit
                            ? const [Color(0xFF059669), Color(0xFF10B981)]
                            : const [Color(0xFFEF4444), Color(0xFFDC2626)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isCredit ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Confirm Ledger Change?',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w900,
                        fontSize: 16.5,
                        color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: themeColor.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User: ${widget.user.email}', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      'Action: ${_isCredit ? "CREDIT" : "DEBIT"} ${CurrencyFormatter.format(entered)}',
                      style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w900, color: themeColor),
                    ),
                    Text(
                      'Resulting: ${CurrencyFormatter.format(newBalance)}',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF38BDF8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _executeAdjustment(entered, newBalance);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().scale(begin: const Offset(0.9, 0.9), duration: 250.ms, curve: Curves.easeOutBack).fade(),
    );
  }

  Future<void> _executeAdjustment(double entered, double newBalance) async {
    CustomLoader.show(context, message: 'Adjusting balance ledger in live vault...');

    bool ok = false;
    try {
      ok = await ref.read(adminProvider.notifier).adjustUserBalance(
            userId: widget.user.id,
            amount: entered,
            type: _isCredit ? 'credit' : 'debit',
            reason: 'SuperAdmin Manual Adjustment',
          );
    } catch (_) {
      ok = false;
    } finally {
      CustomLoader.hide(context);
    }

    if (mounted) {
      if (ok) {
        Navigator.pop(context); // Pop main dialog safely after loader hides
        HapticFeedback.mediumImpact();
        CustomSnackBar.showTopSuccess(
          context: context,
          message:
              'Balance updated to ${CurrencyFormatter.format(newBalance)} for ${widget.user.email}',
          icon: LucideIcons.wallet,
        );
      } else {
        CustomSnackBar.showTopError(
          context: context,
          message: 'Failed to update balance. Please check connection.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final themeColor = _isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444);

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
                ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
                : const [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: themeColor.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.25),
              blurRadius: 28,
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
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isCredit
                          ? const [Color(0xFF059669), Color(0xFF10B981)]
                          : const [Color(0xFFEF4444), Color(0xFFDC2626)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.wallet, color: Colors.white, size: 20),
                ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adjust User Balance',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w900,
                          fontSize: 16.5,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        widget.user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            // Current Balance Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Vault Balance:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(widget.user.balance),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Mode Selector: Credit vs Debit with Vibrant Backgrounds
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isCredit = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _isCredit
                            ? const Color(0xFF10B981).withValues(alpha: 0.20)
                            : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isCredit
                              ? const Color(0xFF10B981)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.plusCircle,
                            size: 15,
                            color: _isCredit
                                ? const Color(0xFF10B981)
                                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '+ Credit Funds',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _isCredit
                                  ? const Color(0xFF10B981)
                                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isCredit = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_isCredit
                            ? const Color(0xFFEF4444).withValues(alpha: 0.20)
                            : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !_isCredit
                              ? const Color(0xFFEF4444)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.minusCircle,
                            size: 15,
                            color: !_isCredit
                                ? const Color(0xFFEF4444)
                                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '- Debit Funds',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: !_isCredit
                                  ? const Color(0xFFEF4444)
                                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Amount Field
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                hintText: 'e.g. 500',
                prefixIcon: const Icon(LucideIcons.indianRupee, size: 16),
                filled: true,
                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: themeColor, width: 1.5)),
              ),
              validator: (v) {
                final d = double.tryParse(v?.trim() ?? '');
                if (d == null || d <= 0) return 'Enter valid amount > 0';
                return null;
              },
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  child: ElevatedButton(
                    onPressed: _confirmAndSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _isCredit ? 'Credit Funds' : 'Debit Funds',
                      style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800),
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
