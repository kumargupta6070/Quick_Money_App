import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/providers/navigation_provider.dart';
import 'admin_dashboard_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_payouts_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_users_screen.dart';

/// Dedicated Super Admin Management Suite Shell.
/// Incorporates the identical cinematic smooth tab transitions and vibrant glowing indicators as MainShell.
class AdminPortalShell extends ConsumerWidget {
  const AdminPortalShell({super.key});

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const AdminDashboardScreen();
      case 1:
        return const AdminUsersScreen();
      case 2:
        return const AdminOrdersScreen();
      case 3:
        return const AdminPayoutsScreen();
      case 4:
        return const AdminSettingsScreen();
      default:
        return const AdminDashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(adminSelectedTabProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adminState = ref.watch(adminProvider);
    final pendingPayouts = adminState.stats.pendingPayoutsCount;

    final inactiveColor = isDark
        ? const Color(0xFF64748B)
        : const Color(0xFF94A3B8);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(currentIndex),
          child: _getScreen(currentIndex),
        ),
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF07112E).withValues(alpha: 0.94)
                  : Colors.white.withValues(alpha: 0.94),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.6)
                      : const Color(0xFF0F2B82).withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context: context,
                      ref: ref,
                      index: 0,
                      currentIndex: currentIndex,
                      label: 'Overview',
                      icon: LucideIcons.layoutDashboard,
                      activeColor: const Color(0xFFF59E0B), // Warm Gold
                      inactiveColor: inactiveColor,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      context: context,
                      ref: ref,
                      index: 1,
                      currentIndex: currentIndex,
                      label: 'Users',
                      icon: LucideIcons.users,
                      activeColor: const Color(0xFF0284C7), // Sky Cyan
                      inactiveColor: inactiveColor,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      context: context,
                      ref: ref,
                      index: 2,
                      currentIndex: currentIndex,
                      label: 'Packages',
                      icon: LucideIcons.packagePlus,
                      activeColor: const Color(0xFF10B981), // Emerald
                      inactiveColor: inactiveColor,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      context: context,
                      ref: ref,
                      index: 3,
                      currentIndex: currentIndex,
                      label: 'Payouts',
                      icon: LucideIcons.arrowDownToLine,
                      badgeCount: pendingPayouts,
                      activeColor: const Color(0xFFEF4444), // Coral Red
                      inactiveColor: inactiveColor,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      context: context,
                      ref: ref,
                      index: 4,
                      currentIndex: currentIndex,
                      label: 'Control',
                      icon: LucideIcons.sliders,
                      activeColor: const Color(0xFF8B5CF6), // Royal Purple
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
    required WidgetRef ref,
    required int index,
    required int currentIndex,
    required String label,
    required IconData icon,
    required Color activeColor,
    required Color inactiveColor,
    required bool isDark,
    int badgeCount = 0,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(adminSelectedTabProvider.notifier).selectTab(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, isSelected ? -2 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.18 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeColor.withValues(alpha: isDark ? 0.45 : 0.30)
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: isDark ? 0.25 : 0.15),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(minWidth: 14),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
