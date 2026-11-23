import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'fintech_spinner_painters.dart';

/// Next-Level, Ultra-Designable, Colorful & Active Animated Custom Loader for Quick Money.
/// Features dual counter-rotating gradient sweep arcs, leading glowing particle heads,
/// breathing central 3D Rupee coin, traveling loading dots, and frosted glass dialogs.
class CustomLoader extends StatefulWidget {
  final double size;
  final String? message;
  final bool showGlow;
  final bool showSubtext;

  const CustomLoader({
    super.key,
    this.size = 68.0,
    this.message,
    this.showGlow = true,
    this.showSubtext = false,
  });

  @override
  State<CustomLoader> createState() => _CustomLoaderState();

  /// Small glowing loader for buttons and inline widgets
  static Widget inline({double size = 20, Color color = const Color(0xFF00E5FF)}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        strokeCap: StrokeCap.round,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  /// Centered loader for screens and tabs
  static Widget centered({String message = 'Loading...'}) {
    return Center(
      child: CustomLoader(
        size: 72,
        message: message,
        showSubtext: true,
      ),
    );
  }

  static BuildContext? _activeLoaderContext;
  static bool _isOpen = false;

  /// Displays an ultra-modern modal loading overlay with backdrop blur & neon glow
  static void show(BuildContext context, {String message = 'Processing...'}) =>
      showOverlay(context, message: message);

  /// Dismisses active overlay loader safely
  static void hide(BuildContext context) => dismiss(context);

  /// Displays the full modal loading overlay
  static void showOverlay(BuildContext context, {String message = 'Processing...'}) {
    if (_isOpen) return;
    _isOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) {
        _activeLoaderContext = ctx;
        return PopScope(
          canPop: false,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 36),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
                decoration: BoxDecoration(
                  color: const Color(0xFF090F24).withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                      blurRadius: 36,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                      blurRadius: 24,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // High-Energy Active Dual-Arc Spinner
                    const CustomLoader(
                      size: 74,
                      showGlow: true,
                    ),

                    const SizedBox(height: 22),

                    // Main Loading Message
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Active Bouncing Loading Dots
                    const CustomLoadingDots(),

                    const SizedBox(height: 12),

                    // Animated Security Beacon Capsule
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
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
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF10B981),
                                  blurRadius: 6,
                                  spreadRadius: 1.5,
                                ),
                              ],
                            ),
                          )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .fade(begin: 0.3, end: 1.0, duration: 600.ms),
                          const SizedBox(width: 6),
                          const Text(
                            'SECURE AES-256 SESSION',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.75, 0.75),
                    end: const Offset(1.0, 1.0),
                    duration: 350.ms,
                    curve: Curves.elasticOut,
                  )
                  .fade(duration: 250.ms),
            ),
          ),
        );
      },
    ).then((_) {
      _isOpen = false;
      _activeLoaderContext = null;
    });
  }

  /// Dismisses active overlay loader safely
  static void dismiss(BuildContext context) {
    if (!_isOpen) return;
    if (_activeLoaderContext != null && _activeLoaderContext!.mounted) {
      Navigator.of(_activeLoaderContext!).pop();
      _isOpen = false;
      _activeLoaderContext = null;
      return;
    }
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    _isOpen = false;
    _activeLoaderContext = null;
  }
}

class _CustomLoaderState extends State<CustomLoader> with TickerProviderStateMixin {
  late final AnimationController _outerController;
  late final AnimationController _innerController;

  @override
  void initState() {
    super.initState();

    // Fast clockwise outer spinner
    _outerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();

    // Slower counter-clockwise inner spinner
    _innerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat();
  }

  @override
  void dispose() {
    _outerController.dispose();
    _innerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // ── Layer 1: Ambient Glowing Halo ──
            if (widget.showGlow)
              Container(
                width: size + 16,
                height: size + 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00E5FF).withValues(alpha: 0.35),
                      const Color(0xFF2563EB).withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(0.85, 0.85), end: const Offset(1.15, 1.15), duration: 1200.ms),

            // ── Layer 2: Fast Clockwise Cyan/Blue Outer Arc with Glowing Head ──
            AnimatedBuilder(
              animation: _outerController,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(size, size),
                  painter: FinTechSpinnerPainter(
                    progress: _outerController.value,
                    primaryColor: const Color(0xFF00E5FF),
                    accentColor: const Color(0xFF2563EB),
                    strokeWidth: 4.2,
                  ),
                );
              },
            ),

            // ── Layer 3: Counter-Clockwise Golden Inner Arc ──
            AnimatedBuilder(
              animation: _innerController,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(size * 0.72, size * 0.72),
                  painter: InnerGoldSpinnerPainter(
                    progress: _innerController.value,
                    strokeWidth: 2.8,
                  ),
                );
              },
            ),

            // ── Layer 4: Center Floating Glass Coin with Glowing Rupee Symbol ──
            Container(
              width: size * 0.44,
              height: size * 0.44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF00E5FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '₹',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.08, 1.08), duration: 800.ms),
          ],
        ),

        // Optional Message for Centered Loader
        if (widget.message != null && widget.message!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            widget.message!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],

        // Optional Subtext for Centered Loader
        if (widget.showSubtext) ...[
          const SizedBox(height: 6),
          const Text(
            'Quick Money • Secure Processing',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ],
    );
  }
}
