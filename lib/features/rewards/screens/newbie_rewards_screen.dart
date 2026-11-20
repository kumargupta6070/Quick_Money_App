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
import '../../../shared/widgets/gradient_text.dart';

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
                _buildHeroHeader(context, isDark)
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: -0.05, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 16),

                // ── 2. 3D Golden Welcome Bonus Hero Banner ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildWelcomeHeroCard(
                    isDark,
                    completedCount,
                    totalTasks,
                    progressPercent,
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
                      _buildTaskTile(
                        context: context,
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
                      _buildTaskTile(
                        context: context,
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
                      _buildTaskTile(
                        context: context,
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
                      _buildTaskTile(
                        context: context,
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
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F1A30).withValues(alpha: 0.85)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFFD97706).withValues(alpha: 0.35)
                            : const Color(0xFFFDE68A),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD97706)
                              .withValues(alpha: isDark ? 0.20 : 0.06),
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
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.sparkles,
                            size: 16,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Instant RP Balance Credit',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'All claimed rewards are instantly reflected in your RP Balance and can be used to purchase higher tier orders or auto-transferred upon ₹100 cumulative profit.',
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

  /// Royal FinTech Curved Hero Header
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
                      'Newbie Rewards',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'Starter investment package & milestone unlocks',
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
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.gift,
                      size: 12,
                      color: Color(0xFFFDE68A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '₹50 BONUS',
                      style: GoogleFonts.spaceGrotesk(
                        color: const Color(0xFFFDE68A),
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
        ),
      ),
    );
  }

  /// 3D Glowing Welcome Bonus Hero Card
  Widget _buildWelcomeHeroCard(
    bool isDark,
    int completedCount,
    int totalTasks,
    int progressPercent,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB45309), Color(0xFFD97706), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.40),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  LucideIcons.gift,
                  size: 36,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'EXCLUSIVE STARTER BONUS',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFDE68A),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GradientText(
                      'Welcome Bonus ₹50',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFFEF3C7)],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Complete your first PhonePe deposit to claim your starter investment package and boost yield up to 2.5%.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.90),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // Progress Track Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Starter Progress',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  Text(
                    '$progressPercent% Completed',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFDE68A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: totalTasks > 0 ? (completedCount / totalTasks) : 0.0,
                  minHeight: 6,
                  backgroundColor: Colors.black.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFDE68A),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// High-End FinTech Task Tile with glowing border and staggered entrance
Widget _buildTaskTile({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String reward,
  required IconData icon,
  required bool isCompleted,
  required Color accentColor,
  required List<Color> gradientColors,
  required int delayMs,
  required bool isDark,
  bool isClaimable = false,
  bool isClaiming = false,
  VoidCallback? onClaim,
  String? actionLabel,
  VoidCallback? onAction,
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
        color: accentColor.withValues(alpha: isDark ? 0.45 : 0.35),
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
    child: Row(
      children: [
        // Icon Container
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentColor, accentColor.withValues(alpha: 0.75)],
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

        // Title & Subtitle Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Reward: ',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    reward,
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFF10B981),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Completion Status / Claim Button / Action Button
        if (isCompleted)
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
                  color: const Color(0xFF10B981).withValues(alpha: 0.30),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.check,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  'CLAIMED',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          )
        else if (isClaimable)
          InkWell(
            onTap: isClaiming ? null : onClaim,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7.5,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF059669),
                    Color(0xFF10B981),
                    Color(0xFF34D399),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.40),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: isClaiming
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.sparkles,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Claim',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          )
        else if (actionLabel != null && onAction != null)
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onAction();
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor,
                    accentColor.withValues(alpha: 0.85),
                  ],
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    LucideIcons.arrowRight,
                    size: 13,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          )
        else
          ElevatedButton(
            onPressed: () {
              CustomSnackBar.showInfo(
                context: context,
                message: 'Fulfill requirement to claim reward.',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Go', style: TextStyle(fontSize: 11.5)),
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
