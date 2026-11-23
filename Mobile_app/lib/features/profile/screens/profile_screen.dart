import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/referral_provider.dart';
import '../../../core/providers/reward_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/wallet_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/profile_balance_card.dart';
import '../widgets/profile_footer_section.dart';
import '../widgets/profile_hero_header.dart';
import '../widgets/profile_services_menu.dart';
import '../widgets/profile_team_rebate_card.dart';
import '../widgets/super_admin_banner.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProfile();
    });
  }

  Future<void> _refreshProfile() async {
    await Future.wait([
      ref.read(userProvider.notifier).fetchProfile(),
      ref.read(walletProvider.notifier).fetchWallet(),
      ref.read(referralProvider.notifier).fetchTeamOverview(),
      ref.read(rewardProvider.notifier).fetchNewbieRewards(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = ref.watch(userProvider);
    final wallet = ref.watch(walletProvider);
    final team = ref.watch(referralProvider);
    final rewards = ref.watch(rewardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user.mobile.isEmpty && !authState.isAuthenticated) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.brandPrimary),
        ),
      );
    }

    final totalRebateYield =
        team.level1Rate + team.level2Rate + team.level3Rate;
    final displayMobile = _hideMobile
        ? (user.mobile.length >= 7
            ? '${user.mobile.substring(0, 3)}****${user.mobile.substring(user.mobile.length - 3)}'
            : '*******')
        : user.mobile;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: AppColors.brandPrimary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 1. Royal FinTech Hero Header with quick stats bar
              ProfileHeroHeader(
                user: user,
                wallet: wallet,
                team: team,
                displayMobile: displayMobile,
                totalRebateYield: totalRebateYield,
                hideMobile: _hideMobile,
                onToggleMobileVisibility: () {
                  setState(() => _hideMobile = !_hideMobile);
                },
                isDark: isDark,
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // 2. Super Admin Exclusive Command Center Banner (Visible only for admin role)
                    if (authState.isAdmin || authState.role == 'admin') ...[
                      SuperAdminBanner(isDark: isDark)
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(
                            begin: -0.1,
                            end: 0,
                            curve: Curves.easeOutBack,
                          ),
                      const SizedBox(height: 16),
                    ],

                    // 3. Current Available Balance Hero Card
                    ProfileBalanceCard(user: user, isDark: isDark)
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 400.ms)
                        .slideY(
                          begin: 0.06,
                          end: 0,
                          curve: Curves.easeOutCubic,
                        ),

                    const SizedBox(height: 16),

                    // 4. Team 3-Level Rebate Card
                    ProfileTeamRebateCard(
                      team: team,
                      totalRebateYield: totalRebateYield,
                      isDark: isDark,
                    )
                        .animate()
                        .fadeIn(delay: 180.ms, duration: 400.ms)
                        .slideY(
                          begin: 0.06,
                          end: 0,
                          curve: Curves.easeOutCubic,
                        ),

                    const SizedBox(height: 18),

                    // 5. Essential Feature Services Menu
                    ProfileServicesMenu(
                      wallet: wallet,
                      rewards: rewards,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 20),

                    // 6. Security Trust Badge & Sign Out Button
                    ProfileFooterSection(isDark: isDark)
                        .animate()
                        .fadeIn(delay: 350.ms, duration: 400.ms)
                        .slideY(
                          begin: 0.08,
                          end: 0,
                          curve: Curves.easeOutCubic,
                        ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
