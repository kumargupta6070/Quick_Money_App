import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../widgets/password_reset_dialog.dart';
import '../widgets/security_compliance_card.dart';
import '../widgets/security_health_card.dart';
import '../widgets/security_hero_header.dart';
import '../widgets/security_item_card.dart';

/// Ultra-Designable, Colorful, and Animated Account Security Screen
/// Orchestrates modular security cards, health indicators, and AES-256 vault actions.
class AccountSecurityScreen extends ConsumerStatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  ConsumerState<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends ConsumerState<AccountSecurityScreen> {
  bool _biometricEnabled = true;
  bool _otpEnabled = true;

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
              child: SecurityHeroHeader(isDark: isDark)
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: -0.05, end: 0, curve: Curves.easeOutCubic),
            ),

            // ── 2. Security Health Score Hero Card ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SecurityHealthCard(isDark: isDark)
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
                    SecurityItemCard(
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
                      onTap: () => PasswordResetDialog.show(context, isDark: isDark),
                      isDark: isDark,
                    ),

                    const SizedBox(height: 10),

                    // Two-Factor Authentication Card (Emerald Theme)
                    SecurityItemCard(
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
                    SecurityItemCard(
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
                    SecurityItemCard(
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
                    SecurityItemCard(
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
                    SecurityItemCard(
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
                child: SecurityComplianceCard(isDark: isDark)
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
}
