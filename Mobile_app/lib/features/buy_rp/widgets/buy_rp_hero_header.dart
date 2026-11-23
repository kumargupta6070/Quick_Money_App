import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quick_money/core/constants/app_constants.dart';
import 'package:quick_money/core/theme/app_colors.dart';
import 'package:quick_money/core/theme/app_spacing.dart';
import 'package:quick_money/features/home/widgets/home_header.dart';

class BuyRpHeroHeader extends StatelessWidget {
  final double balance;
  final int animTrigger;
  final int liveOrdersCount;
  final String selectedLevel;
  final Function(String) onLevelChanged;

  const BuyRpHeroHeader({
    super.key,
    required this.balance,
    required this.animTrigger,
    required this.liveOrdersCount,
    required this.selectedLevel,
    required this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              // HomeHeader Integration
              HomeHeader(
                key: ValueKey('buy_home_header_$animTrigger'),
                balance: balance,
              ),

              const SizedBox(height: 14),

              // Marketplace Subheader Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.20),
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
                          color: Colors.white.withValues(alpha: 0.95),
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
                      color: const Color(0xFF10B981).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.35),
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
                            .fade(begin: 0.3, end: 1.0, duration: 500.ms),
                        const SizedBox(width: 6),
                        Text(
                          '$liveOrdersCount Orders Live',
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

              // Horizontally Scrollable Level Tabs (L1 - L7)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: AppConstants.orderLevels.map((lvl) {
                    final isSelected = lvl == selectedLevel;
                    return GestureDetector(
                      onTap: () {
                        if (!isSelected) {
                          onLevelChanged(lvl);
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
                              : Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF38BDF8)
                                : Colors.white.withValues(alpha: 0.25),
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
    );
  }
}
