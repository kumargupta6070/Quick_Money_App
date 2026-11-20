import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/models/order_model.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../../home/widgets/home_header.dart';

/// Next-Level FinTech Buy RP Marketplace Screen.
/// Built strictly adhering to the ICU Mobile App visual hierarchy,
/// ambient glow orbs, HomeHeader integration, staggered entrance animations,
/// vivid colorful section backgrounds, and zero-overflow layout.
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
            // ── Section 1: Top FinTech Hero Header with HomeHeader & Level Selector ──
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A1B4B),
                    Color(0xFF143BB8),
                    Color(0xFF0C246E),
                  ],
                  stops: [0.0, 0.65, 1.0],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF0F2B82),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                  child: Column(
                    children: [
                      // HomeHeader Integration (Brand emblem, Market Online, Balance pill & Notifications)
                      HomeHeader(
                        key: ValueKey('buy_home_header_$animTrigger'),
                        balance: user.balance,
                      ),

                      const SizedBox(height: 14),

                      // Marketplace Subheader Bar: Title & Active Orders Badge
                      Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF38BDF8)
                                          .withValues(alpha: 0.20),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      LucideIcons.shoppingBag,
                                      size: 14,
                                      color: Color(0xFF38BDF8),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'RP MARKETPLACE',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: Colors.white.withValues(
                                        alpha: 0.95,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: 0.35),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF10B981),
                                          ),
                                        )
                                        .animate(
                                          onPlay: (controller) =>
                                              controller.repeat(reverse: true),
                                        )
                                        .fade(
                                          begin: 0.3,
                                          end: 1.0,
                                          duration: 500.ms,
                                        ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${orderState.orders.length} Orders Live',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF34D399),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                          .animate()
                          .fade(duration: 350.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 14),

                      // Horizontally Scrollable Level Tabs (L1 - L7) (Filter button deleted as requested)
                      SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: AppConstants.orderLevels.map((lvl) {
                                final isSelected =
                                    lvl == orderState.selectedLevel;
                                return GestureDetector(
                                  onTap: () {
                                    if (!isSelected) {
                                      orderNotifier.changeLevel(lvl);
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeOutCubic,
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8.5,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? const LinearGradient(
                                              colors: [
                                                Colors.white,
                                                Color(0xFFE0F2FE),
                                              ],
                                            )
                                          : null,
                                      color: isSelected
                                          ? null
                                          : Colors.white.withValues(
                                              alpha: 0.16,
                                            ),
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusFull,
                                      ),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF38BDF8)
                                            : Colors.white.withValues(
                                                alpha: 0.25,
                                              ),
                                        width: isSelected ? 1.5 : 0.8,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF38BDF8)
                                                    .withValues(alpha: 0.40),
                                                blurRadius: 12,
                                                offset: const Offset(0, 3),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      lvl,
                                      style: GoogleFonts.spaceGrotesk(
                                        color: isSelected
                                            ? AppColors.brandPrimary
                                            : Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: 0.05, end: 0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Section 2: Sorting, Exchange Rate & Refresh Control Bar (Zero Overflow) ──
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF142347), const Color(0xFF0F1A35)]
                      : [const Color(0xFFEBF3FE), const Color(0xFFF1F5F9)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF38BDF8).withValues(alpha: 0.22)
                      : const Color(0xFF38BDF8).withValues(alpha: 0.28),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7)
                        .withValues(alpha: isDark ? 0.20 : 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 1. Sort Toggle Pill (Flexible to guarantee 0 overflow)
                  Expanded(
                    child: InkWell(
                      onTap: () => orderNotifier.toggleSortOrder(),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7)
                              .withValues(alpha: isDark ? 0.24 : 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF0284C7)
                                .withValues(alpha: 0.30),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              orderState.sortOrder == 'low_to_high'
                                  ? LucideIcons.arrowUpNarrowWide
                                  : LucideIcons.arrowDownWideNarrow,
                              size: 13,
                              color: isDark
                                  ? const Color(0xFF38BDF8)
                                  : AppColors.brandPrimary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                orderState.sortOrder == 'low_to_high'
                                    ? 'Low to High'
                                    : 'High to Low',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // 2. Exchange Rate Pill with Amber Background
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706)
                          .withValues(alpha: isDark ? 0.24 : 0.14),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFD97706).withValues(alpha: 0.32),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.zap,
                          size: 11,
                          color: Color(0xFFD97706),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '1 RP = ₹1',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? const Color(0xFFFBBF24)
                                : const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // 3. Animated Refresh Button with Emerald/Cyan Background
                  InkWell(
                    onTap: _handleRefresh,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981)
                            .withValues(alpha: isDark ? 0.22 : 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF10B981)
                              .withValues(alpha: 0.30),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RotationTransition(
                            turns: _refreshRotController,
                            child: Icon(
                              LucideIcons.rotateCcw,
                              size: 12,
                              color: isDark
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFF059669),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Refresh',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade(duration: 350.ms).slideY(begin: 0.08, end: 0),

            // ── Section 3: Orders Marketplace List with Colorful Card Themes ──
            Expanded(
              child: orderState.isLoading
                  ? const Center(
                      child: CustomLoader(
                        size: 40,
                        message: 'Loading live marketplace orders...',
                      ),
                    )
                  : orderState.orders.isEmpty
                  ? _buildEmptyState(
                      context,
                      isDark,
                      orderState.selectedLevel,
                      errorMessage: orderState.errorMessage,
                    )
                  : RefreshIndicator(
                      key: ValueKey(
                        'buy_refresh_${animTrigger}_${orderState.selectedLevel}',
                      ),
                      onRefresh: _handleRefresh,
                      color: AppColors.brandPrimary,
                      backgroundColor: isDark
                          ? const Color(0xFF131D38)
                          : Colors.white,
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
                          return _buildOrderCard(
                            context: context,
                            order: order,
                            ref: ref,
                            index: index,
                            isDark: isDark,
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

  /// Next-Level FinTech Order Card with vivid colorful backgrounds,
  /// glowing accent borders, 3D Receive button, and zero-overflow layout.
  Widget _buildOrderCard({
    required BuildContext context,
    required OrderModel order,
    required WidgetRef ref,
    required int index,
    required bool isDark,
  }) {
    // 4 Distinct Colorful FinTech Themes for Order Cards
    final cardThemes = [
      // 0. Sky Cyan FinTech Theme
      {
        'accent': const Color(0xFF0284C7),
        'lightColors': [const Color(0xFFEFF8FF), const Color(0xFFE2F0FE)],
        'darkColors': [const Color(0xFF102544), const Color(0xFF0B192E)],
        'borderColor': const Color(0xFF38BDF8),
        'badgeBg': const Color(0xFF0284C7),
      },
      // 1. Emerald Green FinTech Theme
      {
        'accent': const Color(0xFF059669),
        'lightColors': [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
        'darkColors': [const Color(0xFF0E2C20), const Color(0xFF091F17)],
        'borderColor': const Color(0xFF34D399),
        'badgeBg': const Color(0xFF059669),
      },
      // 2. Amber Gold FinTech Theme
      {
        'accent': const Color(0xFFD97706),
        'lightColors': [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
        'darkColors': [const Color(0xFF2E210E), const Color(0xFF201608)],
        'borderColor': const Color(0xFFFBBF24),
        'badgeBg': const Color(0xFFD97706),
      },
      // 3. Royal Indigo FinTech Theme
      {
        'accent': const Color(0xFF4F46E5),
        'lightColors': [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
        'darkColors': [const Color(0xFF1C194D), const Color(0xFF131036)],
        'borderColor': const Color(0xFF818CF8),
        'badgeBg': const Color(0xFF4F46E5),
      },
    ];

    final theme = cardThemes[index % cardThemes.length];
    final accentColor = theme['accent'] as Color;
    final bgColors = isDark
        ? (theme['darkColors'] as List<Color>)
        : (theme['lightColors'] as List<Color>);
    final borderColor = theme['borderColor'] as Color;

    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: bgColors,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor.withValues(alpha: isDark ? 0.38 : 0.32),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: isDark ? 0.25 : 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Top Row: Tier badge + PhonePe Guaranteed Shield & Final RP Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // Tier Pill with matching accent background
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(
                                alpha: isDark ? 0.30 : 0.16,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: borderColor.withValues(alpha: 0.45),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              order.level,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDark ? borderColor : accentColor,
                              ),
                            ),
                          ),

                          // PhonePe Guaranteed Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: isDark ? 0.22 : 0.14),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.30),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.shieldCheck,
                                  size: 11,
                                  color: Color(0xFF10B981),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'PhonePe Guaranteed',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFF34D399)
                                        : const Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Final RP Pill (Emerald green glowing pill)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981)
                            .withValues(alpha: isDark ? 0.24 : 0.16),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF10B981)
                              .withValues(alpha: 0.40),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.sparkles,
                            size: 11,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Final: ${order.finalRp} RP',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Card Middle Row: Amount & Quantity on Left, 3D Receive Button on Right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: Large Investment Amount & Order Quantity
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '₹',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? borderColor : accentColor,
                                ),
                              ),
                              const SizedBox(width: 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${order.orderAmount}',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.6,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Order Amount',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),

                          // Order Quantity with Box Icon
                          Row(
                            children: [
                              Icon(
                                LucideIcons.layers,
                                size: 13,
                                color: isDark ? borderColor : accentColor,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  'Available: ${order.orderQuantity} orders',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFFCBD5E1)
                                        : const Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Right: 3D Filled Receive Button
                    GestureDetector(
                      onTap: () => _handleReceiveOrder(context, ref, order),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB)
                                  .withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Receive',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 4),
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

                const SizedBox(height: 10),

                // Card Bottom Strip: Reward & Bonus & Return Note
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    // Reward Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A).withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.gift,
                            size: 11,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Reward: ₹${order.reward}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bonus Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981)
                            .withValues(alpha: isDark ? 0.25 : 0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF10B981)
                              .withValues(alpha: 0.40),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.sparkle,
                            size: 10,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '+₹${order.bonus} Bonus',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // PhonePe Auto-return note
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1)
                            .withValues(alpha: isDark ? 0.20 : 0.14),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF6366F1)
                              .withValues(alpha: 0.30),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.repeat,
                            size: 10,
                            color: Color(0xFF6366F1),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Auto-return upon ₹100 Profit',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFFA5B4FC)
                                  : const Color(0xFF4338CA),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 65 * index))
        .fadeIn(duration: 350.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.10,
          end: 0,
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1.0, 1.0),
          duration: 350.ms,
          curve: Curves.easeOut,
        );
  }

  /// Empty state when no orders are found for the selected tier
  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    String level, {
    String? errorMessage,
  }) {
    final hasError = errorMessage != null && errorMessage.isNotEmpty;
    return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (hasError ? Colors.red : const Color(0xFF0284C7))
                        .withValues(alpha: 0.15),
                    border: Border.all(
                      color: (hasError ? Colors.red : const Color(0xFF0284C7))
                          .withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      hasError
                          ? LucideIcons.alertTriangle
                          : LucideIcons.packageOpen,
                      size: 32,
                      color: hasError ? Colors.red : const Color(0xFF0284C7),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  hasError
                      ? 'Connection Notice'
                      : 'No Orders in Tier $level',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasError
                      ? errorMessage
                      : 'All current orders in $level are currently fulfilled. Switch tiers or refresh to check updated market listings.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _handleRefresh,
                  icon: const Icon(LucideIcons.rotateCcw, size: 14),
                  label: Text(hasError ? 'Retry' : 'Refresh Orders'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.92, 0.92), end: const Offset(1, 1));
  }

  /// Rich FinTech Animated Confirmation Dialog for receiving orders with zero-overflow layout
  void _handleReceiveOrder(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Formatting numbers to prevent floating-point runaway precision errors
    final amountStr = order.orderAmount.truncateToDouble() == order.orderAmount
        ? order.orderAmount.toInt().toString()
        : order.orderAmount.toStringAsFixed(2);
    final rewardStr = order.reward.truncateToDouble() == order.reward
        ? order.reward.toInt().toString()
        : order.reward.toStringAsFixed(2);
    final bonusStr = order.bonus.truncateToDouble() == order.bonus
        ? order.bonus.toInt().toString()
        : order.bonus.toStringAsFixed(1);
    final finalRpStr = order.finalRp.truncateToDouble() == order.finalRp
        ? order.finalRp.toInt().toString()
        : order.finalRp.toStringAsFixed(1);

    showDialog(
      context: context,
      builder: (dialogCtx) =>
          Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF142347), const Color(0xFF0A1428)]
                          : [
                              const Color(0xFFE2F0FD),
                              const Color(0xFFEBF5FE),
                              const Color(0xFFF0F7FF),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF38BDF8).withValues(alpha: 0.45)
                          : const Color(0xFF0284C7).withValues(alpha: 0.50),
                      width: 1.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7)
                            .withValues(alpha: isDark ? 0.45 : 0.20),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dialog Header: Icon, Title, Subtitle and Close
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0284C7),
                                      Color(0xFF2563EB),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0284C7)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  LucideIcons.shoppingBag,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Receive Order',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Review earnings & auto-return',
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
                            ],
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(dialogCtx),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : const Color(0xFFE2E8F0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.x, size: 16),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Highlighted Investment Hero Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xFF1E2E5A),
                                    const Color(0xFF131D38),
                                  ]
                                : [
                                    const Color(0xFFE0F2FE),
                                    const Color(0xFFF0FDF4),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF38BDF8)
                                .withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'INVESTMENT AMOUNT',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: isDark
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFF0369A1),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹$amountStr',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7)
                                    .withValues(alpha: isDark ? 0.30 : 0.18),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF0284C7)
                                      .withValues(alpha: 0.40),
                                ),
                              ),
                              child: Text(
                                '${order.level} Tier',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? const Color(0xFF38BDF8)
                                      : const Color(0xFF0284C7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Breakdown Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xFF0F1A33),
                                    const Color(0xFF091224),
                                  ]
                                : [Colors.white, const Color(0xFFF0FDF4)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF38BDF8)
                                      .withValues(alpha: 0.20)
                                : const Color(0xFF0284C7)
                                      .withValues(alpha: 0.25),
                            width: 1.1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildDialogRow(
                              'Brokerage Reward',
                              '+₹$rewardStr',
                              isDark,
                              icon: LucideIcons.gift,
                              color: const Color(0xFFD97706),
                            ),
                            const Divider(height: 18),
                            _buildDialogRow(
                              'Special Bonus',
                              '+₹$bonusStr',
                              isDark,
                              icon: LucideIcons.sparkle,
                              color: const Color(0xFF10B981),
                            ),
                            const Divider(height: 18),
                            _buildDialogRow(
                              'Final Credited RP',
                              '$finalRpStr RP',
                              isDark,
                              isBold: true,
                              icon: LucideIcons.sparkles,
                              color: const Color(0xFF059669),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // PhonePe Auto-Return Information Banner
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1)
                              .withValues(alpha: isDark ? 0.16 : 0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF6366F1)
                                .withValues(alpha: 0.28),
                            width: 0.9,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF5F259F),
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                'पे',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Automatic PhonePe Return: When cumulative profit hits ₹100, capital + profits auto-transfer to your PhonePe account.',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFFA5B4FC)
                                      : const Color(0xFF4338CA),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Action Buttons: Cancel and Confirm Order
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogCtx),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white30
                                      : const Color(0xFFCBD5E1),
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(dialogCtx);
                                CustomLoader.showOverlay(
                                  context,
                                  message: 'Reserving Order & Crediting RP on Live Gateway...',
                                );

                                final result = await ref
                                    .read(orderProvider.notifier)
                                    .receiveOrder(order.id);

                                if (!context.mounted) return;
                                CustomLoader.dismiss(context);

                                if (result.success) {
                                  CustomSnackBar.showSuccess(
                                    context: context,
                                    message: result.message,
                                    icon: Icons.check_circle_rounded,
                                  );
                                } else {
                                  CustomSnackBar.showError(
                                    context: context,
                                    message: result.message,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandPrimary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Confirm Order',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(LucideIcons.arrowRight, size: 15),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.90, 0.90),
                end: const Offset(1, 1),
                curve: Curves.easeOutBack,
                duration: 350.ms,
              )
              .fadeIn(duration: 350.ms),
    );
  }

  Widget _buildDialogRow(
    String label,
    String value,
    bool isDark, {
    bool isBold = false,
    Color? color,
    IconData? icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color:
                    color ??
                    (isDark ? const Color(0xFF38BDF8) : AppColors.brandPrimary),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13.5,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
                color:
                    color ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
