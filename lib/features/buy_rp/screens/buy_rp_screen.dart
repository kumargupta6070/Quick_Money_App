import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_money/core/providers/navigation_provider.dart';
import 'package:quick_money/core/providers/order_provider.dart';
import 'package:quick_money/core/providers/user_provider.dart';
import 'package:quick_money/core/theme/app_colors.dart';
import 'package:quick_money/core/utils/custom_loader.dart';
import 'package:quick_money/features/buy_rp/widgets/buy_rp_control_bar.dart';
import 'package:quick_money/features/buy_rp/widgets/buy_rp_empty_state.dart';
import 'package:quick_money/features/buy_rp/widgets/buy_rp_hero_header.dart';
import 'package:quick_money/features/buy_rp/widgets/buy_rp_order_card.dart';
import 'package:quick_money/features/buy_rp/widgets/buy_rp_receive_order_dialog.dart';
import 'package:quick_money/shared/widgets/animated_ambient_background.dart';

class BuyRpScreen extends ConsumerStatefulWidget {
  const BuyRpScreen({super.key});

  @override
  ConsumerState<BuyRpScreen> createState() => _BuyRpScreenState();
}

class _BuyRpScreenState extends ConsumerState<BuyRpScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _refreshRotController;

  @override
  void initState() {
    super.initState();
    _refreshRotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _refreshRotController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    _refreshRotController.forward(from: 0.0);
    await ref.read(orderProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final animTrigger = ref.watch(buyRpAnimationTriggerProvider);
    final user = ref.watch(userProvider);
    final orderState = ref.watch(orderProvider);
    final orderNotifier = ref.read(orderProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: AnimatedAmbientBackground(
        child: Column(
          children: [
            // 1. Top FinTech Hero Header with HomeHeader & Level Selector
            BuyRpHeroHeader(
              balance: user.balance,
              animTrigger: animTrigger,
              liveOrdersCount: orderState.orders.length,
              selectedLevel: orderState.selectedLevel,
              onLevelChanged: (lvl) => orderNotifier.changeLevel(lvl),
            ),

            // 2. Sorting, Exchange Rate & Refresh Control Bar
            BuyRpControlBar(
              isDark: isDark,
              sortOrder: orderState.sortOrder,
              onToggleSort: () => orderNotifier.toggleSortOrder(),
              onRefresh: _handleRefresh,
              refreshRotController: _refreshRotController,
            ),

            // 3. Orders Marketplace List
            Expanded(
              child: orderState.isLoading
                  ? const Center(
                      child: CustomLoader(
                        size: 40,
                        message: 'Loading live marketplace orders...',
                      ),
                    )
                  : orderState.orders.isEmpty
                      ? BuyRpEmptyState(
                          isDark: isDark,
                          level: orderState.selectedLevel,
                          errorMessage: orderState.errorMessage,
                          onRefresh: _handleRefresh,
                        )
                      : RefreshIndicator(
                          key: ValueKey(
                            'buy_refresh_${animTrigger}_${orderState.selectedLevel}',
                          ),
                          onRefresh: _handleRefresh,
                          color: AppColors.brandPrimary,
                          backgroundColor:
                              isDark ? const Color(0xFF131D38) : Colors.white,
                          child: ListView.builder(
                            key: ValueKey(
                              'buy_list_${animTrigger}_${orderState.selectedLevel}',
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            itemCount: orderState.orders.length,
                            itemBuilder: (context, index) {
                              final order = orderState.orders[index];
                              return BuyRpOrderCard(
                                order: order,
                                index: index,
                                isDark: isDark,
                                onReceive: () {
                                  BuyRpReceiveOrderDialog.show(
                                    context,
                                    order: order,
                                    isDark: isDark,
                                  );
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
