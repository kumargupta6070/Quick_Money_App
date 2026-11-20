import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_money/core/providers/navigation_provider.dart';
import 'package:quick_money/core/providers/profit_provider.dart';
import 'package:quick_money/core/providers/transaction_provider.dart';
import 'package:quick_money/core/providers/user_provider.dart';
import 'package:quick_money/core/providers/wallet_provider.dart';
import 'package:quick_money/core/theme/app_colors.dart';
import 'package:quick_money/features/sell_rp/widgets/sell_rp_acceleration_sheet.dart';
import 'package:quick_money/features/sell_rp/widgets/sell_rp_hero_header.dart';
import 'package:quick_money/features/sell_rp/widgets/sell_rp_today_overview_card.dart';
import 'package:quick_money/features/sell_rp/widgets/sell_rp_usdt_banner.dart';
import 'package:quick_money/features/sell_rp/widgets/sell_rp_wallet_section.dart';
import 'package:quick_money/shared/widgets/animated_ambient_background.dart';

class SellRpScreen extends ConsumerStatefulWidget {
  const SellRpScreen({super.key});

  @override
  ConsumerState<SellRpScreen> createState() => _SellRpScreenState();
}

class _SellRpScreenState extends ConsumerState<SellRpScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _handleRefresh());
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      ref.read(userProvider.notifier).fetchProfile(),
      ref.read(walletProvider.notifier).fetchWallet(),
      ref.read(profitProvider.notifier).fetchDailyDetails(),
      ref.read(transactionProvider.notifier).fetchTransactions(),
    ]);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final animTrigger = ref.watch(sellRpAnimationTriggerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);
    final wallet = ref.watch(walletProvider);
    final profit = ref.watch(profitProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: AnimatedAmbientBackground(
        child: RefreshIndicator(
          key: ValueKey('sell_refresh_$animTrigger'),
          onRefresh: _handleRefresh,
          color: AppColors.brandPrimary,
          backgroundColor: isDark ? const Color(0xFF131D38) : Colors.white,
          displacement: 40,
          child: CustomScrollView(
            key: ValueKey('sell_scroll_$animTrigger'),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // 1. Top FinTech Curved Hero Banner with HomeHeader
              SliverToBoxAdapter(
                child: SellRpHeroHeader(
                  balance: user.balance,
                  animTrigger: animTrigger,
                ),
              ),

              // 2. Body Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Today's Overview Card
                      SellRpTodayOverviewCard(
                        isDark: isDark,
                        receiptAmount: profit.sellAmount,
                        animIndex: 1,
                      ),

                      const SizedBox(height: 14),

                      // 2. USDT Crypto Top-Up Tutorial Banner
                      const SellRpUsdtBanner(animIndex: 2),

                      const SizedBox(height: 20),

                      // 3. Wallet Information Section & Action Grid
                      SellRpWalletSection(
                        isDark: isDark,
                        wallet: wallet,
                        userBalance: user.balance,
                        onOpenAcceleration: () {
                          SellRpAccelerationSheet.show(
                            context,
                            userBalance: user.balance,
                            isWalletBound: wallet.isBound,
                            onRefresh: _handleRefresh,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
