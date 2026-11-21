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

    bool ok;
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

    if (mounted) {
      CustomLoader.hide(context);
      if (ok) {
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
    const themeColor = Color(0xFF0284C7);

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
              LucideIcons.packagePlus,
              color: themeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isEditing ? 'Edit RP Package' : 'New RP Market Package',
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
            ],
          ),
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
            isEditing ? 'Save Package' : 'Deploy Package',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ).animate().scale(begin: const Offset(0.92, 0.92), duration: 220.ms).fade();
  }
}
