import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../shared/widgets/shared_design_widgets.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_button.dart';

/// Next-Level, High-Impact 3-Slide Animated Onboarding Screen for Quick Money.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'image': AssetPaths.onboarding1,
      'tag': 'MORNING DEPOSIT',
      'tagColor': const Color(0xFF00E5FF),
      'title': 'Smart Morning Investment',
      'description':
          'Add funds easily each morning to unlock active RP orders and start accumulating high-yield daily profits.',
      'chipIcon': LucideIcons.wallet,
      'chipLabel': 'Instant PhonePe & UPI Deposit',
    },
    {
      'image': AssetPaths.onboarding2,
      'tag': 'RP TRADING',
      'tagColor': const Color(0xFFF59E0B),
      'title': 'High-Yield RP Order Trading',
      'description':
          'Execute daily Reward Points (RP) batches from Level 1 to Level 7 with real-time performance tracking.',
      'chipIcon': LucideIcons.trendingUp,
      'chipLabel': 'Guaranteed Daily Commission Yield',
    },
    {
      'image': AssetPaths.onboarding3,
      'tag': 'AUTOMATIC PAYOUT',
      'tagColor': const Color(0xFF10B981),
      'title': 'Automatic ₹100+ Profit Payout',
      'description':
          'Once your profit reaches ₹100, your entire capital plus profit is returned straight to your PhonePe wallet.',
      'chipIcon': LucideIcons.zap,
      'chipLabel': 'Zero-Fee Automatic UPI Payout',
    },
  ];

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return AuthBackground(
      child: Column(
        children: [
          // Top Navigation (Skip Button)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quick Money Brand Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.coins, size: 14, color: Color(0xFFF59E0B)),
                      SizedBox(width: 6),
                      Text(
                        'Quick Money',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),

                // Skip button
                if (_currentPage < _slides.length - 1)
                  TextButton(
                    onPressed: () => context.go('/login'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      backgroundColor: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
          ),

          // Main PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final slide = _slides[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 3D Isometric Illustration
                      LevitatingWidget(
                        distance: 6.0,
                        duration: const Duration(milliseconds: 2400),
                        child: Container(
                          height: size.height * 0.36,
                          constraints: const BoxConstraints(maxHeight: 290),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              slide['image'] as String,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Center(
                                  child: Icon(LucideIcons.image, size: 64, color: Colors.white30),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .scale(begin: const Offset(0.85, 0.85), duration: 500.ms, curve: Curves.easeOutBack)
                          .fade(duration: 400.ms),

                      const SizedBox(height: 24),

                      // Tag Pill
                      GlassCapsuleBadge(
                        label: slide['tag'] as String,
                        dotColor: slide['tagColor'] as Color,
                        borderColor: slide['tagColor'] as Color,
                        fontSize: 11,
                      )
                          .animate()
                          .fade(delay: 150.ms, duration: 400.ms),

                      const SizedBox(height: 14),

                      // Title
                      GradientText(
                        slide['title'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        gradient: isDark
                            ? const LinearGradient(
                                colors: [Colors.white, Color(0xFFE0F2FE), Color(0xFFFDE68A)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                              ),
                      )
                          .animate()
                          .fade(delay: 250.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0, delay: 250.ms, duration: 400.ms),

                      const SizedBox(height: 10),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          slide['description'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                      )
                          .animate()
                          .fade(delay: 350.ms, duration: 400.ms),

                      const SizedBox(height: 14),

                      // Chip
                      FeatureChip(
                        icon: slide['chipIcon'] as IconData,
                        label: slide['chipLabel'] as String,
                        color: slide['tagColor'] as Color,
                      )
                          .animate()
                          .fade(delay: 450.ms, duration: 400.ms),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Controls (Dots Indicator & Next / Get Started Button)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: [
                // Animated Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (index) {
                    final isActive = _currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 7,
                      width: isActive ? 26 : 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF00E5FF)
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // Button
                AuthButton(
                  text: _currentPage == _slides.length - 1 ? 'Get Started' : 'Continue',
                  icon: _currentPage == _slides.length - 1 ? LucideIcons.sparkles : LucideIcons.arrowRight,
                  onPressed: _onNext,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
