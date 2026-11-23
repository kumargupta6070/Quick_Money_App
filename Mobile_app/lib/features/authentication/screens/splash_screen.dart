import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/animations/app_animations.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/shared_design_widgets.dart';
import '../widgets/splash_hero.dart';
import '../widgets/splash_security_badge.dart';

/// Next-Level, High-Impact, Animated Splash Screen for Quick Money.
/// Clean, optimized, modular implementation utilizing shared design widgets.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  String _statusText = 'Initializing Secure Core...';
  bool _isSessionValid = false;
  bool _isSessionAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkActiveSession();

    // Extended duration so users can fully experience the splash screen
    _progressController = AnimationController(
      vsync: this,
      duration: AppAnimations.splash,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    _progressController.addListener(_onProgressTick);

    _progressController.forward().then((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          if (_isSessionValid) {
            if (_isSessionAdmin) {
              context.go('/admin/dashboard');
            } else {
              context.go('/home');
            }
          } else {
            context.go('/login');
          }
        });
      }
    });
  }

  Future<void> _checkActiveSession() async {
    try {
      final valid = await ref.read(authProvider.notifier).checkAndRestoreSession();
      if (!mounted) return;
      final auth = ref.read(authProvider);
      setState(() {
        _isSessionValid = valid;
        _isSessionAdmin = auth.isAdmin;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSessionValid = false;
        });
      }
    }
  }

  void _onProgressTick() {
    final val = _progressController.value;
    String newStatus;

    if (val < 0.28) {
      newStatus = 'Initializing Secure Core...';
    } else if (val < 0.60) {
      newStatus = 'Verifying 7-Day AES-256 Vault Session...';
    } else if (val < 0.88) {
      newStatus = _isSessionValid
          ? (_isSessionAdmin ? 'Admin Authenticated! Restoring...' : 'Session Verified! Syncing Wallet...')
          : 'Connecting to RP Trading Engine...';
    } else {
      newStatus = _isSessionValid ? 'Welcome Back to Quick Money!' : 'Welcome to Quick Money!';
    }

    if (_statusText != newStatus) {
      setState(() => _statusText = newStatus);
    }
  }

  @override
  void dispose() {
    _progressController.removeListener(_onProgressTick);
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF070B18),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Layer 1: Background Splash Art & Rich Gradient ──
          Positioned.fill(
            child: Image.asset(
              AssetPaths.splashBg,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xD9060B1A),
                    Color(0xB30A1430),
                    Color(0xF2040711),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // ── Layer 2: Reusable Ambient Glow Orbs ──
          const Positioned(
            top: -60,
            left: -40,
            child: AmbientGlowOrb(
              size: 240,
              color: Color(0xFF00E5FF),
              maxOpacity: 0.35,
              pulseDuration: Duration(seconds: 3),
            ),
          ),
          Positioned(
            top: size.height * 0.35,
            right: -80,
            child: const AmbientGlowOrb(
              size: 280,
              color: Color(0xFFFFB300),
              maxOpacity: 0.28,
              pulseDuration: Duration(seconds: 4),
            ),
          ),
          Positioned(
            bottom: -50,
            left: size.width * 0.2,
            child: const AmbientGlowOrb(
              size: 260,
              color: Color(0xFF6366F1),
              maxOpacity: 0.30,
              pulseDuration: Duration(milliseconds: 3500),
            ),
          ),

          // ── Layer 3: Main Foreground Content ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ── Hero Section (Levitating Emblem with Rotating Ring) ──
                  const SplashHero(size: 136),

                  const SizedBox(height: 28),

                  // ── App Name with Luxury Gradient Mask ──
                  const GradientText(
                        'QUICK MONEY',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: Colors.white,
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFFFFFF),
                            Color(0xFFE0F2FE),
                            Color(0xFFFDE68A),
                            Color(0xFFFFFFFF),
                          ],
                          stops: [0.0, 0.4, 0.75, 1.0],
                        ),
                      )
                      .animate()
                      .fade(delay: 300.ms, duration: 600.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 300.ms,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: 10),

                  // ── Tagline Glass Capsule Badge ──
                  const GlassCapsuleBadge(
                        label: 'DAILY INVEST • RP TRADING • AUTO RETURN',
                        dotColor: Color(0xFF10B981),
                        borderColor: Color(0xFF00E5FF),
                        fontSize: 10.5,
                      )
                      .animate()
                      .fade(delay: 500.ms, duration: 500.ms)
                      .scale(
                        begin: const Offset(0.85, 0.85),
                        delay: 500.ms,
                        duration: 400.ms,
                      ),

                  const SizedBox(height: 24),

                  // ── 3 Feature Micro-Chips ──
                  const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FeatureChip(
                            icon: LucideIcons.shieldCheck,
                            label: 'AES-256',
                            color: Color(0xFF38BDF8),
                          ),
                          SizedBox(width: 10),
                          FeatureChip(
                            icon: LucideIcons.zap,
                            label: '₹100 Auto Payout',
                            color: Color(0xFFF59E0B),
                          ),
                          SizedBox(width: 10),
                          FeatureChip(
                            icon: LucideIcons.trendingUp,
                            label: 'Daily Profit',
                            color: Color(0xFF10B981),
                          ),
                        ],
                      )
                      .animate()
                      .fade(delay: 700.ms, duration: 500.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        delay: 700.ms,
                        duration: 400.ms,
                      ),

                  const Spacer(flex: 3),

                  // ── Bottom Progress Bar with Dynamic Status Runner ──
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, _) {
                      return GlowingProgressBar(
                        progress: _progressAnimation.value,
                        statusText: _statusText,
                      );
                    },
                  ).animate().fade(delay: 600.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  // ── Bottom Security Reassurance Badge ──
                  const SplashSecurityBadge(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
