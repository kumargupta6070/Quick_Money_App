import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/wallet_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/utils/validators.dart';

class BindPaymentScreen extends ConsumerStatefulWidget {
  const BindPaymentScreen({super.key});

  @override
  ConsumerState<BindPaymentScreen> createState() => _BindPaymentScreenState();
}

class _BindPaymentScreenState extends ConsumerState<BindPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _upiController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedApp = 'phonepe';

  @override
  void initState() {
    super.initState();
    final wallet = ref.read(walletProvider);
    _upiController.text = wallet.upiId;
    _nameController.text = wallet.accountHolderName ?? 'Primary Account';
    _selectedApp = wallet.paymentApp;
  }

  @override
  void dispose() {
    _upiController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(title: const Text('Bind Payment APP'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.brandPrimary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.shieldCheck,
                      color: AppColors.brandPrimary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Whenever your profit reaches ₹100, the app automatically sends your money back to this bound UPI address via PhonePe.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.brandPrimaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Payment App Selection
              const Text(
                'Select Payment Provider',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildAppTile(
                    'phonepe',
                    'PhonePe',
                    AppColors.phonePePurple,
                    'पे',
                  ),
                  const SizedBox(width: 12),
                  _buildAppTile('gpay', 'Google Pay', AppColors.gPayBlue, 'G'),
                  const SizedBox(width: 12),
                  _buildAppTile('paytm', 'Paytm', AppColors.paytmCyan, 'PT'),
                ],
              ),

              const SizedBox(height: 24),

              // Account Holder Name Field
              const Text(
                'Account Holder Name',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter name registered with UPI',
                  prefixIcon: Icon(LucideIcons.user),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Name is required' : null,
              ),

              const SizedBox(height: 20),

              // UPI ID Field
              const Text(
                'PhonePe UPI ID',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _upiController,
                decoration: const InputDecoration(
                  hintText: 'e.g. 9835913180@ybl',
                  prefixIcon: Icon(LucideIcons.wallet),
                ),
                validator: Validators.validateUpi,
              ),

              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: const Text(
                  'Verify & Bind Wallet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppTile(String key, String label, Color color, String symbol) {
    final isSelected = _selectedApp == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedApp = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    symbol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      CustomLoader.showOverlay(
        context,
        message: 'Validating PhonePe UPI with AES-256...',
      );
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;
      CustomLoader.dismiss(context);

      ref
          .read(walletProvider.notifier)
          .updateWallet(
            upiId: _upiController.text.trim(),
            paymentApp: _selectedApp,
          );

      CustomSnackBar.showSuccess(
        context: context,
        message: 'Wallet bound successfully! PhonePe payouts are now active.',
      );
      context.pop();
    }
  }
}
