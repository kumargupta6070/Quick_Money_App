import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/reward_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/wallet_provider.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../widgets/newbie_reward_task_card.dart';
import '../widgets/newbie_rewards_credit_notice.dart';
import '../widgets/newbie_rewards_hero_header.dart';
import '../widgets/newbie_rewards_welcome_card.dart';

/// Next-Level FinTech Newbie Rewards Screen
/// Designed adhering to the ICU Mobile App aesthetic with animated entrance,
/// royal curved hero header, colorful task milestone cards, and zero overflow.
/// Fully integrated with live backend API: GET /api/v1/rewards/newbie & POST /api/v1/rewards/claim.
class NewbieRewardsScreen extends ConsumerStatefulWidget {
  const NewbieRewardsScreen({super.key});

  @override
  ConsumerState<NewbieRewardsScreen> createState() =>
      _NewbieRewardsScreenState();
}

class _NewbieRewardsScreenState extends ConsumerState<NewbieRewardsScreen> {
  int _animSeed = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(rewardProvider.notifier).fetchNewbieRewards();
      ref.read(userProvider.notifier).fetchProfile();
      ref.read(walletProvider.notifier).fetchWallet();
    });
  }

  Future<void> _handleClaim(RewardTask task) async {
    HapticFeedback.mediumImpact();
    final success =
        await ref.read(rewardProvider.notifier).claimReward(task.id);
    if (mounted) {
      if (success) {
        HapticFeedback.heavyImpact();
        CustomSnackBar.showSuccess(
          context: context,
          message:
              '🎉 ${task.rewardText} reward claimed & added to your RP balance!',
          icon: LucideIcons.sparkles,
        );
      } else {
        CustomSnackBar.showError(
          context: context,
          message:
              'Unable to claim reward. Please complete the milestone requirements.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rewardsState = ref.watch(rewardProvider);

    final completedCount = rewardsState.completedCount;
    final totalTasks = rewardsState.totalTasks > 0 ? rewardsState.totalTasks : 4;
    final progressPercent = rewardsState.progressPercent;
    final claimingTaskId = rewardsState.claimingTaskId;

    final task1 = rewardsState.tasks.firstWhere(
      (t) => t.id == 'verify_mobile',
      orElse: () => const RewardTask(
        id: 'verify_mobile',
        title: 'Verify Mobile Number',
        subtitle: 'Primary account phone verification',
        reward: 10.0,
        rewardText: '₹10.00 RP',
        isEligible: true,
        isClaimed: false,
        actionType: 'claim',
      ),
    );

    final task2 = rewardsState.tasks.firstWhere(
      (t) => t.id == 'bind_phonepe',
      orElse: () => const RewardTask(
        id: 'bind_phonepe',
        title: 'Bind PhonePe UPI Address',
        subtitle: 'Enables automatic ₹100 returns to PhonePe',
        reward: 20.0,
        rewardText: '₹20.00 RP',
        isEligible: false,
        isClaimed: false,
        actionType: 'navigate',
        navigationRoute: '/bind-payment',
      ),
    );

    final task3 = rewardsState.tasks.firstWhere(
      (t) => t.id == 'first_order',
      orElse: () => const RewardTask(
        id: 'first_order',
        title: 'Receive First L1 RP Order',
        subtitle: 'Start with ₹100 - ₹300 minimum order trade',
        reward: 20.0,
        rewardText: '₹20.00 RP',
        isEligible: false,
        isClaimed: false,
        actionType: 'navigate',
        navigationRoute: '/buy-rp',
      ),
    );

    final task4 = rewardsState.tasks.firstWhere(
      (t) => t.id == 'first_invite',
      orElse: () => const RewardTask(
        id: 'first_invite',
        title: 'Invite First Team Member',
        subtitle: 'Unlock lifetime 3-level rebate earnings',
        reward: 50.0,
        rewardText: '₹50.00 RP',
        isEligible: false,
        isClaimed: false,
        actionType: 'navigate',
        navigationRoute: '/team',
      ),
    );

    return Scaffold(
      body: AnimatedAmbientBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            setState(() => _animSeed++);
            await Future.wait([
              ref.read(rewardProvider.notifier).fetchNewbieRewards(),
              ref.read(userProvider.notifier).fetchProfile(),
              ref.read(walletProvider.notifier).fetchWallet(),
            ]);
          },
          child: SingleChildScrollView(
            key: ValueKey('rewards_scroll_$_animSeed'),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. Royal FinTech Hero Curved Header ──
                NewbieRewardsHeroHeader(isDark: isDark)
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: -0.05, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 16),

                // ── 2. 3D Golden Welcome Bonus Hero Banner ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: NewbieRewardsWelcomeCard(
                    isDark: isDark,
                    completedCount: completedCount,
                    totalTasks: totalTasks,
                    progressPercent: progressPercent,
                  ),
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

                // ── 3. Section Title ──
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
                                colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Starter Milestone Tasks',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
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
                          '$completedCount of $totalTasks Completed',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 140.ms, duration: 380.ms),

                const SizedBox(height: 12),

                // ── 4. Vibrant Task Cards ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Task 1: Verify Mobile Number
                      NewbieRewardTaskCard(
                        title: task1.title,
                        subtitle: task1.subtitle,
                        reward: task1.rewardText,
                        icon: LucideIcons.smartphone,
                        isCompleted: task1.isClaimed,
                        isClaimable: task1.actionType == 'claim',
                        isClaiming: claimingTaskId == task1.id,
                        onClaim: () => _handleClaim(task1),
                        accentColor: const Color(0xFF10B981),
                        gradientColors: isDark
                            ? [const Color(0xFF0B2B1F), const Color(0xFF103F2E)]
                            : [
                                const Color(0xFFECFDF5),
                                const Color(0xFFD1FAE5),
                              ],
                        delayMs: 180,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 12),

                      // Task 2: Bind PhonePe UPI Address
                      NewbieRewardTaskCard(
                        title: task2.title,
                        subtitle: task2.subtitle,
                        reward: task2.rewardText,
                        icon: LucideIcons.wallet,
                        isCompleted: task2.isClaimed,
                        isClaimable: task2.actionType == 'claim',
                        isClaiming: claimingTaskId == task2.id,
                        onClaim: () => _handleClaim(task2),
                        accentColor: const Color(0xFF8B5CF6),
                        gradientColors: isDark
                            ? [const Color(0xFF21133F), const Color(0xFF311C5E)]
                            : [
                                const Color(0xFFFAF5FF),
                                const Color(0xFFF3E8FF),
                              ],
                        actionLabel: task2.isClaimed || task2.actionType == 'claim'
                            ? null
                            : 'Bind PhonePe',
                        onAction: () => context.push('/bind-payment'),
                        delayMs: 240,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 12),

                      // Task 3: Receive First L1 RP Order
                      NewbieRewardTaskCard(
                        title: task3.title,
                        subtitle: task3.subtitle,
                        reward: task3.rewardText,
                        icon: LucideIcons.shoppingBag,
                        isCompleted: task3.isClaimed,
                        isClaimable: task3.actionType == 'claim',
                        isClaiming: claimingTaskId == task3.id,
                        onClaim: () => _handleClaim(task3),
                        accentColor: const Color(0xFF0284C7),
                        gradientColors: isDark
                            ? [const Color(0xFF0C244C), const Color(0xFF11326E)]
                            : [
                                const Color(0xFFF0F9FF),
                                const Color(0xFFE0F2FE),
                              ],
                        actionLabel: task3.isClaimed || task3.actionType == 'claim'
                            ? null
                            : 'Go to Buy RP',
                        onAction: () => context.go('/buy-rp'),
                        delayMs: 300,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 12),

                      // Task 4: Invite First Team Member (Bonus Task)
                      NewbieRewardTaskCard(
                        title: task4.title,
                        subtitle: task4.subtitle,
                        reward: task4.rewardText,
                        icon: LucideIcons.users,
                        isCompleted: task4.isClaimed,
                        isClaimable: task4.actionType == 'claim',
                        isClaiming: claimingTaskId == task4.id,
                        onClaim: () => _handleClaim(task4),
                        accentColor: const Color(0xFFF59E0B),
                        gradientColors: isDark
                            ? [const Color(0xFF2C1E0A), const Color(0xFF3F2B0E)]
                            : [
                                const Color(0xFFFFFBEB),
                                const Color(0xFFFEF3C7),
                              ],
                        actionLabel: task4.isClaimed || task4.actionType == 'claim'
                            ? null
                            : 'Invite Now',
                        onAction: () => context.push('/team'),
                        delayMs: 360,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── 5. Instant Credit Notice Banner ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: NewbieRewardsCreditNotice(isDark: isDark),
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
