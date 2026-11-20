import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../../core/providers/referral_provider.dart';
import '../../../core/providers/reward_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/wallet_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../../../shared/widgets/animated_counter.dart';
import '../../home/widgets/home_header.dart';

/// Mine (Profile) Screen - Premium FinTech Animated & Responsive Experience
/// Replays cascading entrance animations on every tab switch and pull-to-refresh.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _hideMobile = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userProvider.notifier).fetchProfile();
      ref.read(walletProvider.notifier).fetchWallet();
      ref.read(referralProvider.notifier).fetchTeamOverview();
      ref.read(rewardProvider.notifier).fetchNewbieRewards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final wallet = ref.watch(walletProvider);
    final team = ref.watch(referralProvider);
    final rewards = ref.watch(rewardProvider);
    final animTrigger = ref.watch(mineAnimationTriggerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final rawMobile = user.mobile.isNotEmpty ? user.mobile : user.email;
    final displayMobile = _hideMobile
        ? (rawMobile.length >= 6
              ? '${rawMobile.substring(0, 3)}****${rawMobile.substring(rawMobile.length - 3)}'
              : '*******')
        : rawMobile;

    final l1PercentNum =
        int.tryParse(team.level1Percent.replaceAll('%', '')) ?? 5;
    final l2PercentNum =
        int.tryParse(team.level2Percent.replaceAll('%', '')) ?? 3;
    final l3PercentNum =
        int.tryParse(team.level3Percent.replaceAll('%', '')) ?? 1;
    final totalRebateYield = l1PercentNum + l2PercentNum + l3PercentNum;

    return Scaffold(
      body: AnimatedAmbientBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            ref.read(mineAnimationTriggerProvider.notifier).trigger();
            await Future.wait([
              ref.read(userProvider.notifier).fetchProfile(),
              ref.read(walletProvider.notifier).fetchWallet(),
              ref.read(referralProvider.notifier).fetchTeamOverview(),
              ref.read(rewardProvider.notifier).fetchNewbieRewards(),
            ]);
          },
          child: SingleChildScrollView(
            key: ValueKey('mine_scroll_${animTrigger}_${user.id}'),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              children: [
                // 1. Royal FinTech Curved Hero Header with Glowing Accents
                _buildHeroHeader(
                      context,
                      user,
                      wallet,
                      team,
                      displayMobile,
                      totalRebateYield,
                      isDark,
                    )
                    .animate()
                    .fadeIn(duration: 380.ms)
                    .slideY(begin: -0.06, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 14),

                // 2. Current Balance Hero Card (3D FinTech Card)
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildCurrentBalanceCard(context, user, isDark),
                    )
                    .animate()
                    .fadeIn(delay: 70.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      delay: 70.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 14),

                // 3. Team 3-Level Rebate Card (Vibrant Coral/Rose FinTech Banner)
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildTeamRebateCard(
                        context,
                        team,
                        totalRebateYield,
                        isDark,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 140.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      delay: 140.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 14),

                // 4. Essential FinTech Feature Services (Color-coded Menu)
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildServicesCard(
                        context,
                        wallet,
                        rewards,
                        isDark,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 210.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      delay: 210.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 16),

                // 5. Bank-Grade Security & AES Trust Badge
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSecurityTrustBadge(isDark),
                    )
                    .animate()
                    .fadeIn(delay: 280.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      delay: 280.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 18),

                // 6. Red 3D Outlined Logout Button
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildLogoutButton(context, ref, isDark),
                    )
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      delay: 350.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Royal FinTech Header with ambient glow and embedded Quick Stats Bar
  Widget _buildHeroHeader(
    BuildContext context,
    dynamic user,
    WalletModel wallet,
    TeamOverview team,
    String displayMobile,
    int totalRebateYield,
    bool isDark,
  ) {
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
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D256B).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Ambient decorative background lights
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFF59E0B).withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: -40,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00F0FF).withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  // HomeHeader Integration (Emblem, Title, Balance & Notifications)
                  HomeHeader(balance: user.balance),

                  const SizedBox(height: 18),

                  // Avatar & User Profile Info Row
                  Row(
                    children: [
                      // 3D Double Glowing Avatar
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFFB020),
                                  Color(0xFFEA580C),
                                  Color(0xFFB45309),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.45),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Verified green shield badge
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 14),

                      // User Details & Badges
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Mobile Number & Visibility Toggle
                            Row(
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'MOBILE: $displayMobile',
                                      style: GoogleFonts.spaceGrotesk(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _hideMobile = !_hideMobile);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      _hideMobile
                                          ? LucideIcons.eyeOff
                                          : LucideIcons.eye,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // VIP Badge & Invite Code Wrap
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                // VIP Member Gold Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFEF3C7),
                                        Color(0xFFFDE68A),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.15,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        LucideIcons.crown,
                                        size: 11,
                                        color: Color(0xFFB45309),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'VIP MEMBER',
                                        style: GoogleFonts.spaceGrotesk(
                                          color: const Color(0xFF92400E),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Copyable Invite Code Pill
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    Clipboard.setData(
                                      ClipboardData(text: user.inviteCode),
                                    );
                                    CustomSnackBar.showSuccess(
                                      context: context,
                                      message:
                                          'Invite code copied: ${user.inviteCode}',
                                      icon: LucideIcons.copy,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.12,
                                          ),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Invite: ${user.inviteCode}',
                                          style: GoogleFonts.spaceGrotesk(
                                            color: const Color(0xFF0F172A),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        const Icon(
                                          LucideIcons.copy,
                                          size: 12,
                                          color: AppColors.brandPrimary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Embedded 3-Column Glassmorphic Quick Stats Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                          label: 'Account Balance',
                          value: CurrencyFormatter.format(user.balance),
                          valueColor: Colors.white,
                          icon: LucideIcons.wallet,
                          onTap: () => context.push('/daily-details'),
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: Colors.white.withValues(alpha: 0.20),
                        ),
                        _buildStatColumn(
                          label: 'Team Tier',
                          value: '3-Level ($totalRebateYield%)',
                          valueColor: const Color(0xFFFDE68A),
                          icon: LucideIcons.users,
                          onTap: () => context.push('/team'),
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: Colors.white.withValues(alpha: 0.20),
                        ),
                        _buildStatColumn(
                          label: 'KYC Status',
                          value: wallet.isBound ? 'Verified' : 'Unbound',
                          valueColor: wallet.isBound
                              ? const Color(0xFF86EFAC)
                              : const Color(0xFFFBBF24),
                          icon: wallet.isBound
                              ? LucideIcons.shieldCheck
                              : LucideIcons.alertCircle,
                          onTap: () => context.push('/bind-payment'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              onTap();
            }
          : null,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 11, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 3D FinTech Balance Hero Card with quick action buttons
  Widget _buildCurrentBalanceCard(
    BuildContext context,
    dynamic user,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF132247),
                  const Color(0xFF0C1630),
                  const Color(0xFF162854),
                ]
              : [
                  const Color(0xFFEFF8FF),
                  const Color(0xFFE0F2FE),
                  const Color(0xFFF0FDF4),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xFF38BDF8).withValues(alpha: 0.35)
              : const Color(0xFF0284C7).withValues(alpha: 0.30),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7)
                .withValues(alpha: isDark ? 0.25 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('/daily-details');
          },
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top header: Label + Financial Details link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.sparkles,
                            size: 13,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'CURRENT AVAILABLE BALANCE',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Details',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          LucideIcons.chevronRight,
                          size: 13,
                          color: Color(0xFF0284C7),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Giant Animated Balance
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AnimatedCounter(
                          value: user.balance,
                          decimalDigits: 2,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Quick Action Buttons (Deposit / Withdraw)
                Row(
                  children: [
                    // Deposit / Add Funds Button
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.go('/buy-rp');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0284C7)
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.arrowDownToLine,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Deposit Funds',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Sell RP / Withdraw Button
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.go('/sell-rp');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF059669), Color(0xFF10B981)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.arrowUpFromLine,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Withdraw / Sell',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
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

                const SizedBox(height: 12),

                // Guarantee footer pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.shieldCheck,
                        size: 13,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'PhonePe Gateway Auto-Return active on orders reaching ₹100 profit.',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF6EE7B7)
                                : const Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Team 3-Level Rebate Card (Coral/Rose FinTech Banner)
  Widget _buildTeamRebateCard(
    BuildContext context,
    TeamOverview team,
    int totalRebateYield,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2C1118),
                  const Color(0xFF1E0A10),
                  const Color(0xFF36151E),
                ]
              : [
                  const Color(0xFFFFF1F2),
                  const Color(0xFFFFE4E6),
                  const Color(0xFFFFF7ED),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xFFF43F5E).withValues(alpha: 0.35)
              : const Color(0xFFF43F5E).withValues(alpha: 0.25),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF43F5E)
                .withValues(alpha: isDark ? 0.22 : 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Badge + Illustration
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFF43F5E)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444)
                                .withValues(alpha: 0.30),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.flame,
                            size: 11,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'MY TEAM REBATE',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Headline
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '3-LEVEL ',
                            style: GoogleFonts.spaceGrotesk(
                              color: const Color(0xFFEF4444),
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          TextSpan(
                            text: 'rebate mechanism',
                            style: GoogleFonts.spaceGrotesk(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Invite friends to earn up to $totalRebateYield% perpetual daily commissions on every trade.',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Glowing Team Avatar Container
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFF43F5E)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(LucideIcons.users, size: 28, color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3-Tier Commission Breakdown Pills
          Row(
            children: [
              _buildTierChip(
                'L1 Direct: ${team.level1Percent}',
                const Color(0xFFEF4444),
                isDark,
              ),
              const SizedBox(width: 6),
              _buildTierChip(
                'L2 Team: ${team.level2Percent}',
                const Color(0xFFF59E0B),
                isDark,
              ),
              const SizedBox(width: 6),
              _buildTierChip(
                'L3 Sub: ${team.level3Percent}',
                const Color(0xFF8B5CF6),
                isDark,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3D "View earnings >" Button
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/team');
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFEF4444),
                    Color(0xFFF43F5E),
                    Color(0xFFFB7185),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Team & Earnings',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    LucideIcons.arrowRight,
                    size: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierChip(String label, Color accentColor, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: isDark ? 0.20 : 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.30),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: isDark ? accentColor : accentColor.withValues(alpha: 0.95),
            ),
          ),
        ),
      ),
    );
  }

  /// Essential FinTech Feature Services (Color-coded Menu)
  Widget _buildServicesCard(
    BuildContext context,
    WalletModel wallet,
    NewbieRewardsState rewards,
    bool isDark,
  ) {
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
              CustomSnackBar.showInfo(
                context: context,
                message: 'Connecting to 24/7 Live Customer Support Desk...',
                icon: LucideIcons.headphones,
              );
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

  /// Bank-Grade Security & AES Trust Badge
  Widget _buildSecurityTrustBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B172E) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.shieldCheck,
              size: 18,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '256-Bit Bank-Grade Encryption',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Your assets, UPI tokens & credentials are mathematically secure.',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
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

  /// 3D Red Outlined Logout Button
  Widget _buildLogoutButton(BuildContext context, WidgetRef ref, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _handleLogout(context, ref, isDark);
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: const Color(0xFFEF4444).withValues(alpha: 0.8),
            width: 1.5,
          ),
          foregroundColor: const Color(0xFFEF4444),
          backgroundColor: const Color(0xFFEF4444)
              .withValues(alpha: isDark ? 0.08 : 0.04),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.logOut, size: 18),
            const SizedBox(width: 8),
            Text(
              'Logout Account',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref, bool isDark) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF1E1117),
                      const Color(0xFF160B10),
                      const Color(0xFF0F070B),
                    ]
                  : [
                      const Color(0xFFFFF1F2),
                      const Color(0xFFFFE4E6),
                      const Color(0xFFFAFAFA),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFEF4444)
                  .withValues(alpha: isDark ? 0.45 : 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444)
                    .withValues(alpha: isDark ? 0.30 : 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dual-Ring Glowing Logout Emblem
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.45),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.logOut,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Confirm Sign Out',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to end your active session on Quick Money? You will need to sign in again to access trading.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
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
                        'Keep Active',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444)
                                .withValues(alpha: 0.38),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                          ref.read(authProvider.notifier).logout();
                          context.go('/login');
                          CustomSnackBar.showInfo(
                            context: context,
                            message: 'Logged out successfully.',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Sign Out',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
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
    );
  }
}
