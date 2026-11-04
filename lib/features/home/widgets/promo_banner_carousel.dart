import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Next-Level 3D Promotional Banner Carousel matching Screenshot 4.
class PromoBannerCarousel extends StatefulWidget {
  const PromoBannerCarousel({super.key});

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  final PageController _pageController = PageController();
  int _activeBannerIndex = 0;
  Timer? _autoTimer;

  final List<Map<String, dynamic>> _banners = [
    {
      'tag': 'LEADERBOARD',
      'title': 'Subordinate User Growth Top 10',
      'subtitle': 'Compete for massive weekly community bonus pools',
      'buttonText': 'View Ranks >',
      'route': '/team',
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFDC2626), Color(0xFFEA580C)],
      ),
      'icon': LucideIcons.trophy,
    },
    {
      'tag': 'GUARANTEED RETURN',
      'title': 'Instant PhonePe Profit Return',
      'subtitle': 'Reaching ₹100 profit triggers zero-fee auto refund',
      'buttonText': 'View Rules >',
      'route': '/sell-rp',
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF059669), Color(0xFF0284C7)],
      ),
      'icon': LucideIcons.zap,
    },
    {
      'tag': 'NEWBIE BONUS',
      'title': 'Claim ₹20 Starter Capital',
      'subtitle': 'Unlock 3-day newbie tasks and earn daily commissions',
      'buttonText': 'Claim Now >',
      'route': '/newbie-rewards',
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
      ),
      'icon': LucideIcons.gift,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      final nextIndex = (_activeBannerIndex + 1) % _banners.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          children: [
            SizedBox(
              height: 154,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _banners.length,
                onPageChanged: (index) =>
                    setState(() => _activeBannerIndex = index),
                itemBuilder: (context, index) {
                  final banner = _banners[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: banner['gradient'] as Gradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background Faint Watermark Icon
                          Positioned(
                            right: -10,
                            bottom: -15,
                            child: Icon(
                              banner['icon'] as IconData,
                              size: 110,
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),

                          // Foreground Content
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tag Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.28),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  banner['tag'] as String,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Title
                              Text(
                                banner['title'] as String,
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),

                              const SizedBox(height: 3),

                              // Subtitle
                              Text(
                                banner['subtitle'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),

                              const Spacer(),

                              // Bottom Row with Action Button
                              Align(
                                alignment: Alignment.bottomRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final route = banner['route'] as String;
                                    if (route == '/sell-rp' ||
                                        route == '/buy-rp' ||
                                        route == '/home' ||
                                        route == '/profile') {
                                      context.go(route);
                                    } else {
                                      context.push(route);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black87,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 7,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    banner['buttonText'] as String,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Animated Expanding Capsule Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_banners.length, (index) {
                final isActive = _activeBannerIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 20 : 6,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),
          ],
        )
        .animate()
        .fade(delay: 250.ms, duration: 400.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          delay: 250.ms,
          duration: 400.ms,
        );
  }
}
