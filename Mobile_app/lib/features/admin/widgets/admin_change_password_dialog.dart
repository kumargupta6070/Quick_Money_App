import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';

/// Royal Super Admin Password Change Dialog with 256-bit AES encryption verification.
class AdminChangePasswordDialog extends ConsumerStatefulWidget {
  final bool isDark;

  const AdminChangePasswordDialog({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    return showDialog(
      context: context,
      builder: (_) => AdminChangePasswordDialog(isDark: isDark),
    );
  }

  @override
  ConsumerState<AdminChangePasswordDialog> createState() =>
      _AdminChangePasswordDialogState();
}

class _AdminChangePasswordDialogState
    extends ConsumerState<AdminChangePasswordDialog> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final oldPass = _oldPassController.text.trim();
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    if (oldPass.isEmpty) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Please enter your current administrator password.',
        icon: LucideIcons.key,
      );
      return;
    }
    if (newPass.length < 6) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'New password must be at least 6 characters long.',
        icon: LucideIcons.shieldAlert,
      );
      return;
    }
    if (newPass != confirmPass) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'New password and confirm password do not match.',
        icon: LucideIcons.alertCircle,
      );
      return;
    }

    HapticFeedback.mediumImpact();
    CustomLoader.show(context, message: 'Updating Super Admin Security Vault...');

    bool success = false;
    try {
      success = await ref
          .read(authProvider.notifier)
          .changePassword(oldPassword: oldPass, newPassword: newPass);
    } catch (_) {
      success = false;
    } finally {
      CustomLoader.hide(context);
    }

    if (!mounted) return;

    if (success) {
      Navigator.of(context, rootNavigator: true).pop();
      CustomSnackBar.showTopSuccess(
        context: context,
        message: 'Super Admin password updated successfully!',
        icon: LucideIcons.shieldCheck,
      );
    } else {
      final err =
          ref.read(authProvider).error ??
          'Current password is incorrect or update failed.';
      CustomSnackBar.showTopError(context: context, message: err);
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF0F172A).withValues(alpha: 0.8)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: InputBorder.none,
              prefixIcon: Icon(icon, size: 18, color: const Color(0xFF0284C7)),
              suffixIcon: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  obscure ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 18,
                  color: widget.isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF0284C7);

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
            colors: widget.isDark
                ? const [Color(0xFF0F1E36), Color(0xFF0A1324)]
                : const [Colors.white, Color(0xFFF0F9FF)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: themeColor.withValues(alpha: 0.45), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
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
                        colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withValues(alpha: 0.45),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Icon(LucideIcons.keyRound, color: Colors.white, size: 20),
                  ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change Admin Password',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Update root portal access key',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildField(
                label: 'CURRENT ADMIN PASSWORD',
                controller: _oldPassController,
                obscure: _obscureOld,
                onToggle: () => setState(() => _obscureOld = !_obscureOld),
                icon: LucideIcons.lock,
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'NEW PASSWORD',
                controller: _newPassController,
                obscure: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                icon: LucideIcons.shieldCheck,
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'CONFIRM NEW PASSWORD',
                controller: _confirmPassController,
                obscure: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                icon: LucideIcons.checkCheck,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: widget.isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w700,
                          color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
                          colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          'Update Password',
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
      ),
    ).animate().scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack, duration: 250.ms).fade();
  }
}
