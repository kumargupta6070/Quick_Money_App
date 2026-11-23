import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Security reassurance footer badge for splash and onboarding.
class SplashSecurityBadge extends StatelessWidget {
  const SplashSecurityBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          LucideIcons.lock,
          size: 13,
          color: Color(0xFF64748B),
        ),
        const SizedBox(width: 6),
        Text(
          'PhonePe UPI Compatible • Bank-Grade Security',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.45),
            letterSpacing: 0.3,
          ),
        ),
      ],
    )
        .animate()
        .fade(delay: const Duration(milliseconds: 1000), duration: const Duration(milliseconds: 500));
  }
}

