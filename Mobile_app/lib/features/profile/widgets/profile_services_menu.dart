import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/reward_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/models/wallet_model.dart';

class ProfileServicesMenu extends StatelessWidget {
  final WalletModel wallet;
  final NewbieRewardsState rewards;
  final bool isDark;

  const ProfileServicesMenu({
    super.key,
    required this.wallet,
    required this.rewards,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0C1935), const Color(0xFF081226)]
              : [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2E4E) : const Color(0xFFCBD5E1),
          width: 1.4,
        ),
        boxShadow: AppSpacing.cardShadow(context),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
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
                      'QUICK SERVICES & UTILITIES',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.30),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'All Systems Live',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildMenuItem(
            context: context,
            index: 0,
            icon: LucideIcons.gift,
            iconColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
            title: 'Newbie Rewards',
            subtitle: 'Claim sign-in & daily starter rewards',
            badgeText:
                '${rewards.completedCount}/${rewards.totalTasks} Claimed',
            badgeGradient: rewards.completedCount == rewards.totalTasks
                ? const [Color(0xFF059669), Color(0xFF10B981)]
                : const [Color(0xFFF59E0B), Color(0xFFD97706)],
            tileBgColors: isDark
                ? [const Color(0xFF261904), const Color(0xFF1A1102)]
                : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
            tileBorderColor: const Color(0xFFF59E0B),
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/newbie-rewards');
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context: context,
            index: 1,
            icon: LucideIcons.creditCard,
            iconColors: const [Color(0xFF6B21A8), Color(0xFF9333EA)],
            title: 'Bind payment APP',
            subtitle: 'PhonePe, GPay & UPI auto-settlement',
            badgeText: wallet.isBound ? 'PhonePe Active' : 'Not Bound',
            badgeGradient: wallet.isBound
                ? const [Color(0xFF059669), Color(0xFF10B981)]
                : const [Color(0xFFE11D48), Color(0xFFF43F5E)],
            hasLiveDot: wallet.isBound,
            tileBgColors: isDark
                ? [const Color(0xFF230D3B), const Color(0xFF150724)]
                : [const Color(0xFFFAF5FF), const Color(0xFFF3E8FF)],
            tileBorderColor: const Color(0xFF8B5CF6),
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/bind-payment');
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context: context,
            index: 2,
            icon: LucideIcons.receiptText,
            iconColors: const [Color(0xFF0284C7), Color(0xFF2563EB)],
            title: 'Daily Details',
            subtitle: 'Transaction history, rewards & profit logs',
            badgeText: 'Financial Logs',
            badgeGradient: const [Color(0xFF0284C7), Color(0xFF2563EB)],
            tileBgColors: isDark
                ? [const Color(0xFF0A2244), const Color(0xFF05152B)]
                : [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)],
            tileBorderColor: const Color(0xFF0284C7),
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/daily-details');
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context: context,
            index: 3,
            icon: LucideIcons.helpCircle,
            iconColors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
            title: 'Common problem',
            subtitle: 'FAQs on buying, selling & returns',
            badgeText: 'Knowledge Base',
            badgeGradient: const [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
            tileBgColors: isDark
                ? [const Color(0xFF1B133B), const Color(0xFF0F0B24)]
                : [const Color(0xFFF5F3FF), const Color(0xFFEDE9FE)],
            tileBorderColor: const Color(0xFF7C3AED),
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/faq');
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context: context,
            index: 4,
            icon: LucideIcons.headphones,
            iconColors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            title: 'Online service',
            subtitle: '24/7 priority customer support desk',
            badgeText: '● 24/7 Live Desk',
            badgeGradient: const [Color(0xFF059669), Color(0xFF10B981)],
            tileBgColors: isDark
                ? [const Color(0xFF052A1B), const Color(0xFF02170E)]
                : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
            tileBorderColor: const Color(0xFF10B981),
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/customer-support');
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context: context,
            index: 5,
            icon: LucideIcons.shieldCheck,
            iconColors: const [Color(0xFF06B6D4), Color(0xFF0D9488)],
            title: 'Account security',
            subtitle: 'Password protection & login credentials',
            badgeText: 'AES-256 Vault',
            badgeGradient: const [Color(0xFF0891B2), Color(0xFF06B6D4)],
            tileBgColors: isDark
                ? [const Color(0xFF062833), const Color(0xFF03161C)]
                : [const Color(0xFFECFEFF), const Color(0xFFCFFAFE)],
            tileBorderColor: const Color(0xFF06B6D4),
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/account-security');
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context: context,
            index: 6,
            icon: LucideIcons.send,
            iconColors: const [Color(0xFF0EA5E9), Color(0xFF0284C7)],
            title: 'Official Channel',
            subtitle: 'Join community announcements & signals',
            badgeText: '50K+ Community',
            badgeGradient: const [Color(0xFF0284C7), Color(0xFF0EA5E9)],
            tileBgColors: isDark
                ? [const Color(0xFF0B1E42), const Color(0xFF061126)]
                : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
            tileBorderColor: const Color(0xFF3B82F6),
            onTap: () {
              HapticFeedback.lightImpact();
              CustomSnackBar.showInfo(
                context: context,
                message:
                    'Official Community Channel: Join Telegram & WhatsApp.',
                icon: LucideIcons.send,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required List<Color> iconColors,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required List<Color> tileBgColors,
    required Color tileBorderColor,
    String? badgeText,
    List<Color>? badgeGradient,
    bool hasLiveDot = false,
  }) {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
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
                        alpha: isDark ? 0.15 : 0.06,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Colorful 3D Icon Container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: iconColors,
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
                              fontSize: 14.5,
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
                              fontSize: 11,
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

                    // Optional Gradient Badge Pill
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
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : const Color(0xFFF1F5F9))
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

                    // Chevron Pill
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
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (160 + index * 40).ms, duration: 350.ms)
        .slideX(
          begin: 0.05,
          end: 0,
          delay: (160 + index * 40).ms,
          curve: Curves.easeOutCubic,
        );
  }
}
