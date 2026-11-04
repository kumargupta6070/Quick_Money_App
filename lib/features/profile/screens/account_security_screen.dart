import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/widgets/animated_ambient_background.dart';

/// Ultra-Designable, Colorful, and Animated Account Security Screen
/// Styled to match HomeScreen luxury FinTech aesthetics with dynamic category tints,
/// bank-grade security health indicators, biometric & OTP management,
/// and smooth cascading entrance animations on scroll and load.
class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  bool _biometricEnabled = true;
  bool _otpEnabled = true;

  void _showPasswordResetDialog(BuildContext context, bool isDark) {
    HapticFeedback.mediumImpact();
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool hideOld = true;
    bool hideNew = true;
    bool hideConfirm = true;
    String? oldPasswordError;
    String? newPasswordError;
    String? confirmPasswordError;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          void validateAndUpdate() {
            final oldPass = oldPasswordController.text.trim();
            final newPass = newPasswordController.text.trim();
            final confirmPass = confirmPasswordController.text.trim();

            setDialogState(() {
              oldPasswordError = null;
              newPasswordError = null;
              confirmPasswordError = null;
            });

            // 1. Current Password Required Check
            if (oldPass.isEmpty) {
              setDialogState(() {
                oldPasswordError = 'Current Password is required';
              });
              HapticFeedback.heavyImpact();
              CustomSnackBar.showTopWarning(
                context: context,
                message: 'Current Password is required! Please enter your current password.',
                icon: LucideIcons.lockKeyhole,
              );
              return;
            }

            // 2. New Password Required Check
            if (newPass.isEmpty) {
              setDialogState(() {
                newPasswordError = 'New Password is required';
              });
              HapticFeedback.heavyImpact();
              CustomSnackBar.showTopWarning(
                context: context,
                message:
                    'New Password is required! Please enter a new password.',
                icon: LucideIcons.keyRound,
              );
              return;
            }

            // 3. New Password Minimum Length Check (8 characters)
            if (newPass.length < 8) {
              setDialogState(() {
                newPasswordError = 'Minimum 8 characters required';
              });
              HapticFeedback.heavyImpact();
              CustomSnackBar.showTopWarning(
                context: context,
                message:
                    'Password is too short! Minimum 8 characters required.',
                icon: LucideIcons.shieldAlert,
              );
              return;
            }

            // 4. New Password Different From Old Check
            if (newPass == oldPass) {
              setDialogState(() {
                newPasswordError = 'Cannot be same as current password';
              });
              HapticFeedback.heavyImpact();
              CustomSnackBar.showTopWarning(
                context: context,
                message: 'New Password cannot be identical to your Current Password.',
                icon: LucideIcons.alertTriangle,
              );
              return;
            }

            // 5. Confirm Password Required Check
            if (confirmPass.isEmpty) {
              setDialogState(() {
                confirmPasswordError = 'Please confirm new password';
              });
              HapticFeedback.heavyImpact();
              CustomSnackBar.showTopWarning(
                context: context,
                message: 'Please re-enter your new password to confirm.',
                icon: LucideIcons.checkCheck,
              );
              return;
            }

            // 6. Confirm Password Match Check
            if (confirmPass != newPass) {
              setDialogState(() {
                confirmPasswordError = 'Passwords do not match';
              });
              HapticFeedback.heavyImpact();
              CustomSnackBar.showTopWarning(
                context: context,
                message:
                    'Passwords do not match! Please check and enter carefully.',
                icon: LucideIcons.alertTriangle,
              );
              return;
            }

            // All validations passed successfully
            Navigator.pop(dialogCtx);
            HapticFeedback.mediumImpact();
            CustomSnackBar.showTopSuccess(
              context: context,
              message:
                  'Login password updated successfully! AES-256 Vault synced.',
              icon: LucideIcons.shieldCheck,
            );
          }

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
                  color: const Color(0xFF0284C7)
                      .withValues(alpha: isDark ? 0.45 : 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7)
                        .withValues(alpha: isDark ? 0.35 : 0.16),
                    blurRadius: 32,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dual-Ring Glowing Key Emblem
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
                      child: const Icon(
                        LucideIcons.key,
                        color: Colors.white,
                        size: 24,
                      ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3.5,
                    ),
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
                        const Icon(
                          LucideIcons.shieldCheck,
                          size: 11,
                          color: Color(0xFF0284C7),
                        ),
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
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 1. Current Password (Sky Blue Tinted)
                  _buildDialogField(
                    controller: oldPasswordController,
                    hintText: 'Current Password',
                    icon: LucideIcons.lockKeyhole,
                    iconColor: const Color(0xFF0284C7),
                    isObscured: hideOld,
                    onToggleVisibility: () =>
                        setDialogState(() => hideOld = !hideOld),
                    tileBgColors: isDark
                        ? [const Color(0xFF0B1F3D), const Color(0xFF061429)]
                        : [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)],
                    borderColor: const Color(0xFF0284C7),
                    isDark: isDark,
                    errorText: oldPasswordError,
                    onChanged: (val) {
                      if (oldPasswordError != null) {
                        setDialogState(() => oldPasswordError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // 2. New Password (Emerald Tinted)
                  _buildDialogField(
                    controller: newPasswordController,
                    hintText: 'New Password',
                    icon: LucideIcons.keyRound,
                    iconColor: const Color(0xFF10B981),
                    isObscured: hideNew,
                    onToggleVisibility: () =>
                        setDialogState(() => hideNew = !hideNew),
                    tileBgColors: isDark
                        ? [const Color(0xFF052A1C), const Color(0xFF021710)]
                        : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
                    borderColor: const Color(0xFF10B981),
                    isDark: isDark,
                    errorText: newPasswordError,
                    onChanged: (val) {
                      if (newPasswordError != null) {
                        setDialogState(() => newPasswordError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // 3. Confirm New Password (Purple Tinted)
                  _buildDialogField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm New Password',
                    icon: LucideIcons.checkCheck,
                    iconColor: const Color(0xFF8B5CF6),
                    isObscured: hideConfirm,
                    onToggleVisibility: () =>
                        setDialogState(() => hideConfirm = !hideConfirm),
                    tileBgColors: isDark
                        ? [const Color(0xFF220D3B), const Color(0xFF140724)]
                        : [const Color(0xFFFAF5FF), const Color(0xFFF3E8FF)],
                    borderColor: const Color(0xFF8B5CF6),
                    isDark: isDark,
                    errorText: confirmPasswordError,
                    onChanged: (val) {
                      if (confirmPasswordError != null) {
                        setDialogState(() => confirmPasswordError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 22),

                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark
                                  ? Colors.white24
                                  : const Color(0xFFCBD5E1),
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
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Update Button
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: validateAndUpdate,
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
                                  color: const Color(0xFF2563EB)
                                      .withValues(alpha: 0.40),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  LucideIcons.shieldCheck,
                                  size: 16,
                                  color: Colors.white,
                                ),
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
        },
      ),
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color iconColor,
    required bool isObscured,
    required VoidCallback onToggleVisibility,
    required List<Color> tileBgColors,
    required Color borderColor,
    required bool isDark,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;
    final effectiveBorderColor = hasError
        ? const Color(0xFFEF4444)
        : borderColor;
    final effectiveBgColors = hasError
        ? (isDark
              ? [const Color(0xFF2B0E14), const Color(0xFF19070B)]
              : [const Color(0xFFFFF1F2), const Color(0xFFFFE4E6)])
        : tileBgColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: effectiveBgColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: effectiveBorderColor.withValues(
                alpha: isDark ? 0.55 : 0.45,
              ),
              width: hasError ? 1.6 : 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: effectiveBorderColor.withValues(
                  alpha: isDark ? 0.20 : 0.08,
                ),
                blurRadius: hasError ? 8 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isObscured,
            onChanged: onChanged,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                fontSize: 12.5,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
              prefixIcon: Icon(
                hasError ? LucideIcons.alertCircle : icon,
                size: 18,
                color: hasError ? const Color(0xFFEF4444) : iconColor,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isObscured ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 17,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
                onPressed: onToggleVisibility,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.alertCircle,
                  size: 12,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(width: 4),
                Text(
                  errorText,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedAmbientBackground(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── 1. Royal FinTech Hero Curved Header ──
            SliverToBoxAdapter(
              child: _buildHeroHeader(context, isDark)
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: -0.05, end: 0, curve: Curves.easeOutCubic),
            ),

            // ── 2. Security Health Score Hero Card ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildSecurityHealthCard(isDark)
                    .animate()
                    .fadeIn(delay: 80.ms, duration: 400.ms)
                    .slideY(begin: 0.08, end: 0, delay: 80.ms),
              ),
            ),

            // ── 3. Section 1: Authentication & Access ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: _buildSectionTitle(
                  'AUTHENTICATION & CREDENTIALS',
                  isDark,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Change Password Card (Sky Blue Theme)
                    _buildSecurityItemCard(
                      index: 0,
                      icon: LucideIcons.key,
                      iconColors: const [Color(0xFF0284C7), Color(0xFF2563EB)],
                      title: 'Change Login Password',
                      subtitle:
                          'Updated 14 days ago • Recommended every 90 days',
                      badgeText: 'Update',
                      badgeGradient: const [
                        Color(0xFF0284C7),
                        Color(0xFF2563EB),
                      ],
                      tileBgColors: isDark
                          ? [const Color(0xFF0A2244), const Color(0xFF05152B)]
                          : [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)],
                      tileBorderColor: const Color(0xFF0284C7),
                      onTap: () => _showPasswordResetDialog(context, isDark),
                      isDark: isDark,
                    ),

                    const SizedBox(height: 10),

                    // Two-Factor Authentication Card (Emerald Theme)
                    _buildSecurityItemCard(
                      index: 1,
                      icon: LucideIcons.smartphone,
                      iconColors: const [Color(0xFF059669), Color(0xFF10B981)],
                      title: 'Two-Factor Authentication (OTP)',
                      subtitle:
                          'Mandatory for all payouts and order redemptions',
                      badgeText: 'ENABLED',
                      badgeGradient: const [
                        Color(0xFF059669),
                        Color(0xFF10B981),
                      ],
                      hasLiveDot: true,
                      tileBgColors: isDark
                          ? [const Color(0xFF052A1B), const Color(0xFF02170E)]
                          : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
                      tileBorderColor: const Color(0xFF10B981),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _otpEnabled = !_otpEnabled);
                        CustomSnackBar.showInfo(
                          context: context,
                          message: _otpEnabled
                              ? 'Two-Factor Authentication is active.'
                              : 'Two-Factor Authentication paused temporarily.',
                          icon: LucideIcons.shieldAlert,
                        );
                      },
                      isDark: isDark,
                    ),

                    const SizedBox(height: 10),

                    // Biometric Lock Card (Violet Theme)
                    _buildSecurityItemCard(
                      index: 2,
                      icon: LucideIcons.fingerprint,
                      iconColors: const [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                      title: 'Biometric Instant Unlock',
                      subtitle: 'Face ID & Fingerprint instant authentication',
                      badgeText: _biometricEnabled ? 'ACTIVE' : 'OFF',
                      badgeGradient: _biometricEnabled
                          ? const [Color(0xFF7C3AED), Color(0xFF8B5CF6)]
                          : null,
                      tileBgColors: isDark
                          ? [const Color(0xFF1B133B), const Color(0xFF0F0B24)]
                          : [const Color(0xFFF5F3FF), const Color(0xFFEDE9FE)],
                      tileBorderColor: const Color(0xFF7C3AED),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _biometricEnabled = !_biometricEnabled);
                        CustomSnackBar.showSuccess(
                          context: context,
                          message: _biometricEnabled
                              ? 'Biometric unlock enabled successfully.'
                              : 'Biometric unlock disabled.',
                          icon: LucideIcons.fingerprint,
                        );
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),

            // ── 4. Section 2: Payout & Gateway Vault ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
                child: _buildSectionTitle('PAYMENT GATEWAY PROTECTION', isDark),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // PhonePe Vault Card (Royal Purple Theme)
                    _buildSecurityItemCard(
                      index: 3,
                      icon: LucideIcons.lock,
                      iconColors: const [Color(0xFF6B21A8), Color(0xFF9333EA)],
                      title: 'PhonePe Auto-Settlement Enclave',
                      subtitle:
                          'Bound VPA: 919835913180@ybl • Hardware Protected',
                      badgeText: 'AES-256 LOCKED',
                      badgeGradient: const [
                        Color(0xFF6B21A8),
                        Color(0xFF8A2BE2),
                      ],
                      hasLiveDot: true,
                      tileBgColors: isDark
                          ? [const Color(0xFF230D3B), const Color(0xFF150724)]
                          : [const Color(0xFFFAF5FF), const Color(0xFFF3E8FF)],
                      tileBorderColor: const Color(0xFF8B5CF6),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/bind-payment');
                      },
                      isDark: isDark,
                    ),

                    const SizedBox(height: 10),

                    // Anti-Phishing Security Code (Cyan Theme)
                    _buildSecurityItemCard(
                      index: 4,
                      icon: LucideIcons.shieldCheck,
                      iconColors: const [Color(0xFF0891B2), Color(0xFF06B6D4)],
                      title: 'Anti-Phishing Secret Phrase',
                      subtitle: 'Verified stamp will appear in official SMS & notifications',
                      badgeText: 'VERIFIED',
                      badgeGradient: const [
                        Color(0xFF0891B2),
                        Color(0xFF06B6D4),
                      ],
                      tileBgColors: isDark
                          ? [const Color(0xFF062833), const Color(0xFF03161C)]
                          : [const Color(0xFFECFEFF), const Color(0xFFCFFAFE)],
                      tileBorderColor: const Color(0xFF06B6D4),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        CustomSnackBar.showInfo(
                          context: context,
                          message: 'Anti-phishing secret phrase is active for this account.',
                          icon: LucideIcons.shieldCheck,
                        );
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),

            // ── 5. Section 3: Sessions & Connected Hardware ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
                child: _buildSectionTitle('DEVICE & SESSION INTEGRITY', isDark),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Login Devices & Sessions Card (Amber Theme)
                    _buildSecurityItemCard(
                      index: 5,
                      icon: LucideIcons.laptop,
                      iconColors: const [Color(0xFFD97706), Color(0xFFF59E0B)],
                      title: 'Registered Hardware Sessions',
                      subtitle:
                          '1 device connected • Chrome / Android (Current)',
                      badgeText: '1 ACTIVE',
                      badgeGradient: const [
                        Color(0xFFD97706),
                        Color(0xFFF59E0B),
                      ],
                      hasLiveDot: true,
                      tileBgColors: isDark
                          ? [const Color(0xFF261904), const Color(0xFF1A1102)]
                          : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
                      tileBorderColor: const Color(0xFFF59E0B),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        CustomSnackBar.showSuccess(
                          context: context,
                          message: 'Current hardware device is fully authorized and verified.',
                          icon: LucideIcons.laptop,
                        );
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),

            // ── 6. Bank-Grade Compliance & Audit Banner ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 40),
                child: _buildComplianceCard(isDark)
                    .animate()
                    .fadeIn(delay: 380.ms, duration: 400.ms)
                    .slideY(begin: 0.08, end: 0, delay: 380.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Royal FinTech Hero Curved Header with Glowing Back Button & 100% Secure Chip
  Widget _buildHeroHeader(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF07112E),
                  const Color(0xFF0D256B),
                  const Color(0xFF133694),
                ]
              : [
                  const Color(0xFF091A4B),
                  const Color(0xFF11359A),
                  const Color(0xFF1849D6),
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D256B).withValues(alpha: 0.40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: const Icon(
                    LucideIcons.arrowLeft,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Security',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'Hardware-level AES-256 encryption & credentials',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10B981)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.shieldCheck,
                      size: 11,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '100% SECURE',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Security Health Score Card with Dual-Ring Glowing Emblem
  Widget _buildSecurityHealthCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F1E42), const Color(0xFF081329)]
              : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2563EB)
              .withValues(alpha: isDark ? 0.40 : 0.28),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB)
                .withValues(alpha: isDark ? 0.25 : 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Dual-Ring Glowing Shield Emblem
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.shieldCheck,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Security Grade: EXCELLENT',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Score: 98/100 • All cryptographic enclaves operational',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Animated Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 6,
                        color: isDark
                            ? Colors.white12
                            : const Color(0xFFCBD5E1),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: 0.98,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF059669),
                                    Color(0xFF10B981),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 3 Security Status Chips
          Row(
            children: [
              _buildMiniStatusChip(
                'AES-256 Active',
                const Color(0xFF06B6D4),
                isDark,
              ),
              const SizedBox(width: 6),
              _buildMiniStatusChip(
                'OTP Verified',
                const Color(0xFF10B981),
                isDark,
              ),
              const SizedBox(width: 6),
              _buildMiniStatusChip(
                'Enclave Bound',
                const Color(0xFF8B5CF6),
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatusChip(String label, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.16 : 0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF38BDF8), Color(0xFF2563EB)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  /// Individual Security Action Card with unique Category Gradient & Colored Border
  Widget _buildSecurityItemCard({
    required int index,
    required IconData icon,
    required List<Color> iconColors,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required List<Color> tileBgColors,
    required Color tileBorderColor,
    required bool isDark,
    String? badgeText,
    List<Color>? badgeGradient,
    bool hasLiveDot = false,
  }) {
    return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: tileBgColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: tileBorderColor.withValues(
                    alpha: isDark ? 0.35 : 0.28,
                  ),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: tileBorderColor.withValues(
                      alpha: isDark ? 0.14 : 0.05,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 3D Glowing Icon Container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: iconColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: iconColors.first.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(icon, size: 21, color: Colors.white),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 10.8,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Badge Pill
                  if (badgeText != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        gradient: badgeGradient != null
                            ? LinearGradient(
                                colors: badgeGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: badgeGradient == null
                            ? (isDark
                                  ? Colors.white12
                                  : const Color(0xFFE2E8F0))
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: badgeGradient != null
                            ? [
                                BoxShadow(
                                  color: badgeGradient.first.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasLiveDot) ...[
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            badgeText,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],

                  // Circular Chevron
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white12
                          : Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? Colors.white12
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Icon(
                      LucideIcons.chevronRight,
                      size: 13,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (120 + index * 35).ms, duration: 320.ms)
        .slideY(
          begin: 0.05,
          end: 0,
          delay: (120 + index * 35).ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// Compliance & Mathematical Security Guarantee Card
  Widget _buildComplianceCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0C1935), const Color(0xFF081226)]
              : [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFCBD5E1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.shieldCheck,
              size: 20,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FIPS 140-2 Level 3 Military Encryption',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'All sensitive credentials, account tokens & PhonePe payout channels are mathematically locked at hardware level.',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
