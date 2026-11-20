import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/gradient_text.dart';
import '../../../shared/widgets/rotating_ring_emblem.dart';
import '../../notification/providers/notification_provider.dart';

/// Next-Level FinTech Header with brand emblem, live balance pill, and dynamic notifications.
/// Fully connected to live backend APIs: GET /api/v1/users/profile & GET /api/v1/notifications.
class HomeHeader extends ConsumerStatefulWidget {
  final double? balance;

  const HomeHeader({super.key, this.balance});

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userProvider.notifier).fetchProfile();
      ref.read(notificationProvider.notifier).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final currentBalance = widget.balance ?? user.balance;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand Emblem & Title with interactive quick-refresh
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(userProvider.notifier).fetchProfile();
            ref.read(notificationProvider.notifier).fetchNotifications();
          },
          child: Row(
            children: [
              RotatingRingEmblem(
                size: 44,
                ringWidth: 2.0,
                child: Image.asset(
                  AssetPaths.appIcon,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GradientText(
                    'Quick Money',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      color: Colors.white,
                    ),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.white,
                        Color(0xFFE0F2FE),
                        Color(0xFFFDE68A),
                      ],
                    ),
                  ),
                  Row(
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
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .fade(begin: 0.4, end: 1.0, duration: 600.ms),
                      const SizedBox(width: 5),
                      Text(
                        'MARKET ONLINE',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
            .animate()
            .fade(duration: 400.ms)
            .slideX(begin: -0.15, end: 0, duration: 400.ms),

        // Right side: Live Balance Pill & Notification Bell
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing Gold Live Balance Pill
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/daily-details');
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.zap,
                      color: Color(0xFFF59E0B),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        CurrencyFormatter.format(currentBalance),
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFFFDE68A),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fade(delay: 200.ms, duration: 400.ms)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  delay: 200.ms,
                  duration: 400.ms,
                ),

            const SizedBox(width: 8),

            // Notification Bell with dynamic live unread badge count
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/notifications');
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF334155),
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      LucideIcons.bell,
                      color: Colors.white,
                      size: 18,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: -5,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFEF4444),
                                Color(0xFFDC2626),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF0F172A),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEF4444)
                                    .withValues(alpha: 0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                            ),
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1.08, 1.08),
                              duration: 800.ms,
                            ),
                      ),
                  ],
                ),
              ),
            )
                .animate()
                .fade(delay: 300.ms, duration: 400.ms),
          ],
        ),
      ],
    );
  }
}
