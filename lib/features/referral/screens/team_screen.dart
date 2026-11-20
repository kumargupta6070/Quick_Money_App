import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/referral_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../widgets/team_hero_header.dart';
import '../widgets/team_network_kpis.dart';
import '../widgets/team_payout_notice_card.dart';
import '../widgets/team_tier_card.dart';

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
                TeamHeroHeader(
                  isDark: isDark,
                  inviteCode: user.inviteCode,
                  totalEarnings: team.totalEarnings,
                  copied: _copied,
                  onCopy: () => _copyInviteCode(user.inviteCode),
                  onShare: () => _shareCode(user.inviteCode),
                )
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: -0.05, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 16),

                // ── 2. Network Performance KPI Metrics Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TeamNetworkKpis(isDark: isDark, team: team),
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
                      TeamTierCard(
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
                      TeamTierCard(
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
                      TeamTierCard(
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
                  child: TeamPayoutNoticeCard(isDark: isDark),
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
}
