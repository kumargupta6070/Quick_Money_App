import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../features/admin/screens/admin_portal_shell.dart';
import 'floating_support_button.dart';

/// Main Application Shell containing the 4 primary tabs: Home, Buy RP, Sell RP, Mine.
/// Built adhering to the ICU Mobile App navigation shell architecture with smooth translation,
/// subtle glassmorphic backdrop, glowing active indicators, and floating support.
/// Re-triggers full entrance animations whenever the user switches back to the Home tab.
class MainShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  void _onTap(int index) {
    final isCurrent = index == widget.navigationShell.currentIndex;
    widget.navigationShell.goBranch(index, initialLocation: isCurrent);

    if (index == 0) {
      ref.read(homeAnimationTriggerProvider.notifier).trigger();
    } else if (index == 1) {
      ref.read(buyRpAnimationTriggerProvider.notifier).trigger();
    } else if (index == 2) {
      ref.read(sellRpAnimationTriggerProvider.notifier).trigger();
    } else if (index == 3) {
      ref.read(mineAnimationTriggerProvider.notifier).trigger();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (authState.isAdmin || authState.role == 'admin') {
      return const AdminPortalShell();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = widget.navigationShell.currentIndex;

    final activeColor = isDark
        ? const Color(0xFF38BDF8)
        : AppColors.brandPrimary;
    final inactiveColor = isDark
        ? const Color(0xFF64748B)
        : const Color(0xFF94A3B8);

    return Scaffold(
      body: widget.navigationShell,
      floatingActionButton: const FloatingSupportButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0A122C).withValues(alpha: 0.92)
                  : Colors.white.withValues(alpha: 0.92),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.6)
                      : const Color(0xFF1A44B8).withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context: context,
                      index: 0,
                      currentIndex: currentIndex,
                      label: 'Home',
                      icon: LucideIcons.home,
                      activeIcon: Icons.home_rounded,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      isDark: isDark,
                    ),
                    _buildRpNavItem(
                      context: context,
                      index: 1,
                      currentIndex: currentIndex,
                      label: 'Buy RP',
                      isCircle: true,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      isDark: isDark,
                    ),
                    _buildRpNavItem(
                      context: context,
                      index: 2,
                      currentIndex: currentIndex,
                      label: 'Sell RP',
                      isCircle: false,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      context: context,
                      index: 3,
                      currentIndex: currentIndex,
                      label: 'Mine',
                      icon: LucideIcons.user,
                      activeIcon: Icons.person_rounded,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required Color activeColor,
    required Color inactiveColor,
    required bool isDark,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, isSelected ? -2 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.14 : 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeColor.withValues(alpha: isDark ? 0.40 : 0.25)
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: isDark ? 0.20 : 0.10),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                  isSelected ? activeIcon : icon,
                  size: 22,
                  color: isSelected ? activeColor : inactiveColor,
                )
                .animate(target: isSelected ? 1 : 0)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1.12, 1.12),
                  duration: 250.ms,
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : inactiveColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Specialized RP badge tab item matching reference UI exactly with active glow
  Widget _buildRpNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required String label,
    required bool isCircle,
    required Color activeColor,
    required Color inactiveColor,
    required bool isDark,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, isSelected ? -2 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.14 : 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeColor.withValues(alpha: isDark ? 0.40 : 0.25)
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: isDark ? 0.20 : 0.10),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: isCircle ? null : BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? activeColor : inactiveColor,
                      width: 1.5,
                    ),
                    gradient: isSelected
                        ? LinearGradient(
                            colors: isDark
                                ? const [Color(0xFF38BDF8), Color(0xFF2563EB)]
                                : const [Color(0xFF1A44B8), Color(0xFF3B82F6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : Colors.transparent,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.35),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'RP',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : inactiveColor,
                      ),
                    ),
                  ),
                )
                .animate(target: isSelected ? 1 : 0)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1.12, 1.12),
                  duration: 250.ms,
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : inactiveColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
