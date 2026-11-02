import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/custom_snackbar.dart';

/// Floating Chat/Support Action Button visible on all main screens.
/// Styled with a vibrant royal blue gradient, headphone icon, and subtle pulsing glow.
class FloatingSupportButton extends StatelessWidget {
  final VoidCallback? onTap;

  const FloatingSupportButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            CustomSnackBar.showInfo(
              context: context,
              message: 'Connecting to 24/7 Live Support Agent...',
              icon: LucideIcons.headphones,
            );
          },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse halo
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandPrimary.withValues(alpha: 0.25),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.15, 1.15), duration: 1200.ms),

          // Main FAB button
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2563EB), Color(0xFF0F2B82)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandPrimary.withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                LucideIcons.headphones,
                color: Colors.white,
                size: 24,
              ),
            ),
          )
              .animate()
              .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }
}

