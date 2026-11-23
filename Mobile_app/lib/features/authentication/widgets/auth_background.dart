import 'package:flutter/material.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../shared/widgets/ambient_glow_orb.dart';

/// Next-Level FinTech Atmospheric Background for all Auth screens.
/// Features the signature dark navy mesh splash background, glowing cyan/gold/purple
/// ambient orbs, and glassmorphic depth for an ultra-premium visual experience.
class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF070B18),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Layer 1: High-Tech Wave Wallpaper ──
          Positioned.fill(
            child: Image.asset(
              AssetPaths.splashBg,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),

          // ── Layer 2: Deep Midnight Navy Gradient Overlay ──
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

          // ── Layer 3: Vibrant Ambient Glowing Orbs ──
          // Top Cyan Orb
          const Positioned(
            top: -50,
            left: -40,
            child: AmbientGlowOrb(
              size: 240,
              color: Color(0xFF00E5FF),
              maxOpacity: 0.32,
              pulseDuration: Duration(seconds: 4),
            ),
          ),

          // Center-Right Amber Gold Orb
          Positioned(
            top: size.height * 0.35,
            right: -70,
            child: const AmbientGlowOrb(
              size: 280,
              color: Color(0xFFFFB300),
              maxOpacity: 0.25,
              pulseDuration: Duration(seconds: 5),
            ),
          ),

          // Bottom Purple/Indigo Orb
          Positioned(
            bottom: -50,
            left: size.width * 0.15,
            child: const AmbientGlowOrb(
              size: 260,
              color: Color(0xFF6366F1),
              maxOpacity: 0.28,
              pulseDuration: Duration(milliseconds: 3500),
            ),
          ),

          // ── Layer 4: Interactive Foreground Content ──
          SafeArea(child: child),
        ],
      ),
    );
  }
}
