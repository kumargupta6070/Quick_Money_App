import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/referral_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../../../shared/widgets/gradient_text.dart';

/// Next-Level FinTech Team & Earnings Screen
/// Designed adhering to the ICU Mobile App aesthetic with animated entrance,
/// royal curved hero header, colorful 3-level tier cards, and zero overflow.
class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> {
  int _animSeed = 0;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(referralProvider.notifier).fetchTeamOverview());
  }

  void _copyInviteCode(String code) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: code));
    setState(() => _copied = true);
    CustomSnackBar.showSuccess(
      context: context,
      message: 'Invite code $code copied to clipboard!',
      icon: LucideIcons.copyCheck,
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _shareCode(String code) {
    HapticFeedback.mediumImpact();
    Clipboard.setData(
      ClipboardData(
        text:
            'Join Quick Money FinTech! Use my invite code: $code and earn ₹50 Welcome Bonus instantly: https://quickmoney.app/join?ref=$code',
      ),
    );
    CustomSnackBar.showSuccess(
      context: context,
      message: 'Referral link copied! Share with your friends.',
      icon: LucideIcons.share2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final team = ref.watch(referralProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedAmbientBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            setState(() => _animSeed++);
            await ref.read(referralProvider.notifier).fetchTeamOverview();
          },
          child: SingleChildScrollView(
            key: ValueKey('team_scroll_$_animSeed'),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. Royal FinTech Hero Curved Header ──
                _buildHeroHeader(context, isDark, user.inviteCode, team.totalEarnings)
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: -0.05, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 16),

                // ── 2. Network Performance KPI Metrics Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildNetworkKpis(isDark, team),
                )
                    .animate()
                    .fadeIn(delay: 80.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      delay: 80.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 20),

                // ── 3. 3-Level Rebate Breakdown Section Header ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '3-Level Rebate Structure',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.28),
                          ),
                        ),
                        child: Text(
                          'Active 3X Boost',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 140.ms, duration: 380.ms),

                const SizedBox(height: 12),

                // ── 4. Vibrant 3-Level Cards ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Level 1: Direct Referrals (Cyan/Blue Theme)
                      _buildTierCard(
                        context: context,
                        level: 'Level 1 (Direct)',
                        tagText: '${team.level1Percent} Rebate Yield',
                        members: '${team.level1Members} Members',
                        earnings: CurrencyFormatter.format(team.level1Earnings),
                        subtext: 'Direct invitees purchasing RP orders',
                        icon: LucideIcons.userCheck,
                        gradientColors: isDark
                            ? [const Color(0xFF0C244C), const Color(0xFF11326E)]
                            : [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)],
                        borderColor: const Color(0xFF0284C7),
                        accentColor: const Color(0xFF0284C7),
                        delayMs: 180,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 12),

                      // Level 2: Indirect Referrals (Purple Theme)
                      _buildTierCard(
                        context: context,
                        level: 'Level 2 (Indirect)',
                        tagText: '${team.level2Percent} Rebate Yield',
                        members: '${team.level2Members} Members',
                        earnings: CurrencyFormatter.format(team.level2Earnings),
                        subtext: 'Invited by your direct team members',
                        icon: LucideIcons.users,
                        gradientColors: isDark
                            ? [const Color(0xFF21133F), const Color(0xFF311C5E)]
                            : [const Color(0xFFFAF5FF), const Color(0xFFF3E8FF)],
                        borderColor: const Color(0xFF8B5CF6),
                        accentColor: const Color(0xFF8B5CF6),
                        delayMs: 240,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 12),

                      // Level 3: Community Referrals (Emerald Green Theme)
                      _buildTierCard(
                        context: context,
                        level: 'Level 3 (Community)',
                        tagText: '${team.level3Percent} Rebate Yield',
                        members: '${team.level3Members} Members',
                        earnings: CurrencyFormatter.format(team.level3Earnings),
                        subtext: 'Extended downstream network volume',
                        icon: LucideIcons.network,
                        gradientColors: isDark
                            ? [const Color(0xFF0B2B1F), const Color(0xFF103F2E)]
                            : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
                        borderColor: const Color(0xFF10B981),
                        accentColor: const Color(0xFF10B981),
                        delayMs: 300,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── 5. Auto-Settlement Notice Banner ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F1A30).withValues(alpha: 0.85)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF1E3A8A).withValues(alpha: 0.35)
                            : const Color(0xFFBFDBFE),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withValues(
                            alpha: isDark ? 0.25 : 0.05,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.shieldCheck,
                            size: 16,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Instant PhonePe Auto-Settlement',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'All team rebates are credited in real-time. Once your account profit reaches ₹100, funds are automatically remitted to your bound PhonePe account.',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 360.ms, duration: 400.ms)
                    .slideY(begin: 0.08, end: 0, delay: 360.ms),

                const SizedBox(height: 20),

                // ── 6. Bottom Floating Action CTA Button ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: () => _shareCode(user.inviteCode),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
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
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.40),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.share2,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Share Referral Link & Boost 3X',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 420.ms, duration: 400.ms)
                    .slideY(begin: 0.08, end: 0, delay: 420.ms),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Royal FinTech Header with glowing earnings hero
  Widget _buildHeroHeader(BuildContext context, bool isDark, String inviteCode, double totalEarnings) {
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with Frosted Back Button & Live Badge
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
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
                          'My Team & Earnings',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          '3-tier affiliate network & commission yield',
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
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'LIVE',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Glowing 3D Total Earnings Display Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0B1B44).withValues(alpha: 0.85),
                      const Color(0xFF1E3A8A).withValues(alpha: 0.75),
                      const Color(0xFF2563EB).withValues(alpha: 0.65),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF60A5FA).withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.sparkles,
                          size: 15,
                          color: Color(0xFFFDE68A),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'TOTAL REFERRAL REBATES EARNED',
                          style: GoogleFonts.spaceGrotesk(
                            color: const Color(0xFFE0F2FE),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    GradientText(
                      CurrencyFormatter.format(totalEarnings),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        color: Colors.white,
                      ),
                      gradient: const LinearGradient(
                        colors: [
                          Colors.white,
                          Color(0xFFE0F2FE),
                          Color(0xFFFDE68A),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Frosted Invite Code Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.ticket,
                            color: Color(0xFFFDE68A),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  'Invite Code: ',
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    inviteCode,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.spaceGrotesk(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => _copyInviteCode(inviteCode),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _copied
                                    ? const Color(0xFF10B981)
                                    : Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _copied
                                      ? const Color(0xFF10B981)
                                      : Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _copied ? LucideIcons.check : LucideIcons.copy,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _copied ? 'Copied' : 'Copy',
                                    style: GoogleFonts.spaceGrotesk(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => _shareCode(inviteCode),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Share',
                                style: GoogleFonts.spaceGrotesk(
                                  color: const Color(0xFF1E3A8A),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
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
      ),
    );
  }

  /// Network KPI Metrics: 3 FinTech mini tiles with vibrant gradients and staggered animations
  Widget _buildNetworkKpis(bool isDark, [TeamOverview? team]) {
    final t = team ?? const TeamOverview();
    final totalMembers = t.level1Members + t.level2Members + t.level3Members;

    return Row(
      children: [
        Expanded(
          child: _buildMiniKpi(
            title: 'Direct Team',
            value: '${t.level1Members} Users',
            subtitle: '${t.level1Percent} Tier',
            icon: LucideIcons.userPlus,
            color: const Color(0xFF0284C7),
            gradientColors: isDark
                ? [const Color(0xFF082F49), const Color(0xFF0C4A6E)]
                : [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)],
            delayMs: 80,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniKpi(
            title: 'Network Size',
            value: '$totalMembers Users',
            subtitle: '3 Tiers',
            icon: LucideIcons.network,
            color: const Color(0xFF8B5CF6),
            gradientColors: isDark
                ? [const Color(0xFF2E1065), const Color(0xFF3B0764)]
                : [const Color(0xFFF3E8FF), const Color(0xFFE9D5FF)],
            delayMs: 140,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniKpi(
            title: 'Daily Volume',
            value: CurrencyFormatter.format(t.dailyVolume),
            subtitle: 'Active RP',
            icon: LucideIcons.trendingUp,
            color: const Color(0xFF10B981),
            gradientColors: isDark
                ? [const Color(0xFF064E3B), const Color(0xFF065F46)]
                : [const Color(0xFFD1FAE5), const Color(0xFFA7F3D0)],
            delayMs: 200,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniKpi({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Color> gradientColors,
    required int delayMs,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => HapticFeedback.lightImpact(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.45 : 0.35),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.25 : 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 15, color: isDark ? Colors.white : color),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.35)
                          : color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: delayMs.ms, duration: 400.ms)
        .scale(
          begin: const Offset(0.90, 0.90),
          delay: delayMs.ms,
          curve: Curves.easeOutBack,
        );
  }

  /// High-End FinTech Tier Card with glowing border and staggered entrance
  Widget _buildTierCard({
    required BuildContext context,
    required String level,
    required String tagText,
    required String members,
    required String earnings,
    required String subtext,
    required IconData icon,
    required List<Color> gradientColors,
    required Color borderColor,
    required Color accentColor,
    required int delayMs,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor.withValues(alpha: isDark ? 0.45 : 0.35),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.20 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon Badge
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),

              // Title & Commission Tag
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            level,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.30),
                            ),
                          ),
                          child: Text(
                            tagText,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtext,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Earnings Display
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    earnings,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Earned',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Bottom Info Strip: Member Count & Activity Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.usersRound,
                      size: 13,
                      color: accentColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      members,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '100% Guaranteed Payout',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delayMs.ms, duration: 400.ms)
        .slideY(
          begin: 0.08,
          end: 0,
          delay: delayMs.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
