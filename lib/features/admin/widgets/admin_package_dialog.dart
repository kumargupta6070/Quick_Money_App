import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/models/order_model.dart';

class AdminPackageDialog extends ConsumerStatefulWidget {
  final OrderModel? package;
  final bool isDark;

  const AdminPackageDialog({
    super.key,
    this.package,
    required this.isDark,
  });

  @override
  ConsumerState<AdminPackageDialog> createState() => _AdminPackageDialogState();
}

class _AdminPackageDialogState extends ConsumerState<AdminPackageDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _rewardCtrl;
  late final TextEditingController _bonusCtrl;
  late String _level;

  @override
  void initState() {
    super.initState();
    final p = widget.package;
    _amountCtrl = TextEditingController(text: p?.orderAmount.toStringAsFixed(0) ?? '500');
    _qtyCtrl = TextEditingController(text: p?.orderQuantity.toString() ?? '1');
    _rewardCtrl = TextEditingController(text: p?.reward.toStringAsFixed(2) ?? '12.50');
    _bonusCtrl = TextEditingController(text: p?.bonus.toStringAsFixed(1) ?? '2.0');
    _level = p?.level ?? 'L1';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _qtyCtrl.dispose();
    _rewardCtrl.dispose();
    _bonusCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.pop(context);
    final isEditing = widget.package != null;
    final amt = double.parse(_amountCtrl.text.trim());
    final qty = int.parse(_qtyCtrl.text.trim());
    final rew = double.parse(_rewardCtrl.text.trim());
    final bon = double.parse(_bonusCtrl.text.trim());

    CustomLoader.show(
      context,
      message: isEditing ? 'Updating package...' : 'Deploying RP package...',
    );

    bool ok = false;
    try {
      if (isEditing) {
        ok = await ref.read(adminProvider.notifier).updatePackage(
              id: widget.package!.id,
              orderAmount: amt,
              orderQuantity: qty,
              reward: rew,
              bonus: bon,
              level: _level,
              status: widget.package?.status.name ?? 'active',
            );
      } else {
        ok = await ref.read(adminProvider.notifier).createPackage(
              orderAmount: amt,
              orderQuantity: qty,
              reward: rew,
              bonus: bon,
              level: _level,
              status: 'active',
            );
      }
    } catch (_) {
      ok = false;
    } finally {
      if (mounted) {
        CustomLoader.hide(context);
      }
    }

    if (mounted) {
      if (ok) {
        Navigator.of(context).pop();
        HapticFeedback.mediumImpact();
        CustomSnackBar.showTopSuccess(
          context: context,
          message: isEditing
              ? 'Package updated successfully!'
              : 'New RP Package created and deployed!',
          icon: LucideIcons.packageCheck,
        );
      } else {
        CustomSnackBar.showTopError(
          context: context,
          message: 'Failed to save package. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isEditing = widget.package != null;
    const themeColor = Color(0xFF8B5CF6);

    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      content: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF261044), Color(0xFF150928)]
                : const [Colors.white, Color(0xFFFAF5FF)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: themeColor.withValues(alpha: 0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withValues(alpha: 0.45),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Icon(
                        isEditing ? LucideIcons.pencil : LucideIcons.packagePlus,
                        color: Colors.white,
                        size: 20,
                      ),
                    ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Edit RP Package' : 'New RP Market Package',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w900,
                              fontSize: 16.5,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            isEditing ? 'Update market pricing & rewards' : 'Deploy a new liquidity package tier',
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
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  initialValue: _level,
                  decoration: InputDecoration(
                    labelText: 'Market Level Tier',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: ['L1', 'L2', 'L3', 'L4', 'L5', 'L6', 'L7']
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (v) => setState(() => _level = v ?? 'L1'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountCtrl,
                  decoration: InputDecoration(
                    labelText: 'Order Amount (₹)',
                    prefixIcon: const Icon(LucideIcons.indianRupee, size: 16),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid amount' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _qtyCtrl,
                  decoration: InputDecoration(
                    labelText: 'Order Quantity',
                    prefixIcon: const Icon(LucideIcons.layers, size: 16),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid quantity' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _rewardCtrl,
                        decoration: InputDecoration(
                          labelText: 'Reward (RP)',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) => (double.tryParse(v ?? '') ?? -1) < 0 ? 'Valid reward' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _bonusCtrl,
                        decoration: InputDecoration(
                          labelText: 'Bonus (%)',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) => (double.tryParse(v ?? '') ?? -1) < 0 ? 'Valid bonus' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
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
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: themeColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            isEditing ? 'Save Package' : 'Deploy Package',
                            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack, duration: 250.ms).fade();
  }
}
