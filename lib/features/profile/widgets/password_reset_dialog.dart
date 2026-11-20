import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';
import 'password_field_tile.dart';

/// Password Reset Dialog with AES-256 vault animation and real backend verification
class PasswordResetDialog extends ConsumerStatefulWidget {
  final bool isDark;

  const PasswordResetDialog({
    super.key,
    required this.isDark,
  });

  static Future<void> show(BuildContext context, {required bool isDark}) {
    HapticFeedback.mediumImpact();
    return showDialog(
      context: context,
      builder: (dialogCtx) => PasswordResetDialog(isDark: isDark),
    );
  }

  @override
  ConsumerState<PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends ConsumerState<PasswordResetDialog> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hideOld = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  String? _oldPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateAndUpdate() {
    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    setState(() {
      _oldPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    if (oldPass.isEmpty) {
      setState(() => _oldPasswordError = 'Current Password is required');
      HapticFeedback.heavyImpact();
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Current Password is required! Please enter your current password.',
        icon: LucideIcons.lockKeyhole,
      );
      return;
    }

    if (newPass.isEmpty) {
      setState(() => _newPasswordError = 'New Password is required');
      HapticFeedback.heavyImpact();
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'New Password is required! Please enter a new password.',
        icon: LucideIcons.keyRound,
      );
      return;
    }

    if (newPass.length < 8) {
      setState(() => _newPasswordError = 'Minimum 8 characters required');
      HapticFeedback.heavyImpact();
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Password is too short! Minimum 8 characters required.',
        icon: LucideIcons.shieldAlert,
      );
      return;
    }

    if (newPass == oldPass) {
      setState(() => _newPasswordError = 'Cannot be same as current password');
      HapticFeedback.heavyImpact();
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'New Password cannot be identical to your Current Password.',
        icon: LucideIcons.alertTriangle,
      );
      return;
    }

    if (confirmPass.isEmpty) {
      setState(() => _confirmPasswordError = 'Please confirm new password');
      HapticFeedback.heavyImpact();
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Please re-enter your new password to confirm.',
        icon: LucideIcons.checkCheck,
      );
      return;
    }

    if (confirmPass != newPass) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      HapticFeedback.heavyImpact();
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Passwords do not match! Please check and enter carefully.',
        icon: LucideIcons.alertTriangle,
      );
      return;
    }

    CustomLoader.show(context, message: 'Syncing 256-Bit Password Vault...');
    ref.read(authProvider.notifier).changePassword(
      oldPassword: oldPass,
      newPassword: newPass,
    ).then((success) {
      if (!mounted) return;
      CustomLoader.hide(context);

      if (success) {
        Navigator.pop(context);
        HapticFeedback.mediumImpact();
        CustomSnackBar.showTopSuccess(
          context: context,
          message: 'Login password updated successfully! AES-256 Vault synced.',
          icon: LucideIcons.shieldCheck,
        );
      } else {
        final err = ref.read(authProvider).error ??
            'Failed to update password. Please check your current password.';
        CustomSnackBar.showTopError(
          context: context,
          message: err,
        );
      }
    }).catchError((_) {
      if (!mounted) return;
      CustomLoader.hide(context);
      CustomSnackBar.showTopError(
        context: context,
        message: 'Network error. Please try again.',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF0F1E42),
                    const Color(0xFF0A142E),
                    const Color(0xFF070F24),
                  ]
                : [
                    const Color(0xFFF0F9FF),
                    const Color(0xFFE0F2FE),
                    const Color(0xFFEFF6FF),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.45 : 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.35 : 0.16),
              blurRadius: 32,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF0284C7),
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.key, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(height: 14),

            Text(
              'Change Login Password',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.shieldCheck, size: 11, color: Color(0xFF0284C7)),
                  const SizedBox(width: 5),
                  Text(
                    'AES-256 BANK ENCRYPTION',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Create a strong password with at least 8 characters.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 18),

            // 1. Current Password
            PasswordFieldTile(
              controller: _oldPasswordController,
              hintText: 'Current Password',
              icon: LucideIcons.lockKeyhole,
              iconColor: const Color(0xFF0284C7),
              isObscured: _hideOld,
              onToggleVisibility: () => setState(() => _hideOld = !_hideOld),
              tileBgColors: isDark
                  ? [const Color(0xFF0B1F3D), const Color(0xFF061429)]
                  : [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)],
              borderColor: const Color(0xFF0284C7),
              isDark: isDark,
              errorText: _oldPasswordError,
              onChanged: (val) {
                if (_oldPasswordError != null) {
                  setState(() => _oldPasswordError = null);
                }
              },
            ),
            const SizedBox(height: 10),

            // 2. New Password
            PasswordFieldTile(
              controller: _newPasswordController,
              hintText: 'New Password',
              icon: LucideIcons.keyRound,
              iconColor: const Color(0xFF10B981),
              isObscured: _hideNew,
              onToggleVisibility: () => setState(() => _hideNew = !_hideNew),
              tileBgColors: isDark
                  ? [const Color(0xFF052A1C), const Color(0xFF021710)]
                  : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
              borderColor: const Color(0xFF10B981),
              isDark: isDark,
              errorText: _newPasswordError,
              onChanged: (val) {
                if (_newPasswordError != null) {
                  setState(() => _newPasswordError = null);
                }
              },
            ),
            const SizedBox(height: 10),

            // 3. Confirm New Password
            PasswordFieldTile(
              controller: _confirmPasswordController,
              hintText: 'Confirm New Password',
              icon: LucideIcons.checkCheck,
              iconColor: const Color(0xFF8B5CF6),
              isObscured: _hideConfirm,
              onToggleVisibility: () => setState(() => _hideConfirm = !_hideConfirm),
              tileBgColors: isDark
                  ? [const Color(0xFF220D3B), const Color(0xFF140724)]
                  : [const Color(0xFFFAF5FF), const Color(0xFFF3E8FF)],
              borderColor: const Color(0xFF8B5CF6),
              isDark: isDark,
              errorText: _confirmPasswordError,
              onChanged: (val) {
                if (_confirmPasswordError != null) {
                  setState(() => _confirmPasswordError = null);
                }
              },
            ),
            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                        width: 1.3,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: _validateAndUpdate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0284C7),
                            Color(0xFF2563EB),
                            Color(0xFF1D4ED8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.40),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.shieldCheck, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            'Update Password',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
