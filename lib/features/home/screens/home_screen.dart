import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock_data/app_mock_data.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../widgets/home_header.dart';
import '../widgets/live_payout_ticker.dart';
import '../widgets/promo_banner_carousel.dart';
import '../widgets/quick_actions_bar.dart';
import '../widgets/stats_summary_card.dart';
import '../widgets/tutorial_section.dart';

/// Next-Level FinTech Animated Dashboard Screen for Quick Money,
/// built strictly adhering to the ICU Mobile App visual hierarchy,
/// ambient glow orbs, staggered entrance animations, and cohesive design tokens.
/// Re-triggers full entrance animations every time the user returns to this tab.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Watches the tab switch animation trigger so all animations replay upon returning
    final animTrigger = ref.watch(homeAnimationTriggerProvider);
    final user = ref.watch(userProvider);
    final stats = AppMockData.homeStats;

    return Scaffold(
      body: AnimatedAmbientBackground(
        child: RefreshIndicator(
          key: ValueKey('home_refresh_$animTrigger'),
          onRefresh: _handleRefresh,
          color: const Color(0xFF00E5FF),
          backgroundColor: const Color(0xFF0A122C),
          displacement: 40,
          child: CustomScrollView(
            key: ValueKey('home_scroll_$animTrigger'),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── 1. Top FinTech Hero Header & Promotional Carousel ──
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF0A1B4B),
                        Color(0xFF143BB8),
                        Color(0xFF0C246E),
                      ],
                      stops: [0.0, 0.65, 1.0],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F2B82).withValues(alpha: 0.45),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        // Top Header Bar: Logo emblem, Market Online, Balance pill & Notifications
                        HomeHeader(
                          key: ValueKey('home_header_$animTrigger'),
                          balance: user.balance,
                        ),

                        const SizedBox(height: 18),

                        // 3D Animated Promotional Banner Carousel
                        PromoBannerCarousel(
                          key: ValueKey('home_promo_$animTrigger'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── 2. Staggered Animated Content Body ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      // Quick Action Shortcuts with colorful backgrounds (ICU Mobile App style pills)
                      QuickActionsBar(
                        key: ValueKey('home_actions_$animTrigger'),
                      ),

                      const SizedBox(height: 14),

                      // Live Community Payout Ticker Marquee
                      LivePayoutTicker(
                        key: ValueKey('home_ticker_$animTrigger'),
                      ),

                      const SizedBox(height: 20),

                      // ICU-Style 2x2 Vivid KPI Metrics Grid with high-contrast text
                      StatsSummaryCard(
                        key: ValueKey('home_stats_$animTrigger'),
                        stats: stats,
                      ),

                      const SizedBox(height: 24),

                      // Interactive Tutorials & Step-by-Step Guides Section
                      TutorialSection(
                        key: ValueKey('home_tutorials_$animTrigger'),
                      ),

                      const SizedBox(height: 80), // Bottom navigation clearance
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
