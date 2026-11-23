import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../widgets/admin_order_package_card.dart';
import '../widgets/admin_package_dialog.dart';
import '../widgets/admin_screen_hero_header.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  final List<String> _levels = ['ALL', 'L1', 'L2', 'L3', 'L4', 'L5', 'L6', 'L7'];
  String _selectedLevel = 'ALL';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProvider.notifier).fetchPackages();
    });
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    CustomLoader.show(context, message: 'Refreshing RP packages...');
    try {
      await ref.read(adminProvider.notifier).fetchPackages(
            level: _selectedLevel == 'ALL' ? null : _selectedLevel,
          );
    } finally {
      if (mounted) CustomLoader.hide(context);
    }
  }

  void _filterLevel(String lvl) {
    HapticFeedback.selectionClick();
    setState(() => _selectedLevel = lvl);
    ref.read(adminProvider.notifier).fetchPackages(
          level: lvl == 'ALL' ? null : lvl,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adminState = ref.watch(adminProvider);
    final packages = adminState.packages;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AdminPackageDialog(isDark: isDark),
          );
        },
        backgroundColor: const Color(0xFF0284C7),
        icon: const Icon(LucideIcons.plus, color: Colors.white, size: 18),
        label: Text(
          'New RP Package',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
      body: AnimatedAmbientBackground(
        darkGradientColors: const [
          Color(0xFF1A0B2E),
          Color(0xFF2E1065),
          Color(0xFF140724),
        ],
        lightGradientColors: const [
          Color(0xFFFAF5FF),
          Color(0xFFF3E8FF),
          Color(0xFFF5F3FF),
        ],
        primaryOrbColor: const Color(0xFF8B5CF6),
        secondaryOrbColor: const Color(0xFFA855F7),
        tertiaryOrbColor: const Color(0xFFEC4899),
        child: Column(
          children: [
            // 1. Signature Royal FinTech Header with HomeHeader
            AdminScreenHeroHeader(
              title: 'RP Market Packages',
              icon: LucideIcons.packagePlus,
              badgeText: '${packages.length} Active',
              badgeColor: const Color(0xFF0284C7),
              bottom: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _levels.map((lvl) {
                    final isSelected = lvl == _selectedLevel;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _filterLevel(lvl),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF0284C7),
                                      Color(0xFF2563EB),
                                    ],
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : Colors.black.withValues(alpha: 0.32),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF38BDF8)
                                  : Colors.white.withValues(alpha: 0.25),
                              width: 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF0284C7)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            lvl,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 2. Packages List with Staggered Entrance Animations
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: const Color(0xFF0284C7),
                child: packages.isEmpty && !adminState.isLoading
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                        itemCount: packages.length,
                        itemBuilder: (context, i) {
                          return AdminOrderPackageCard(
                            package: packages[i],
                            isDark: isDark,
                          )
                              .animate(delay: Duration(milliseconds: 40 * i))
                              .fadeIn(duration: 250.ms)
                              .slideY(begin: 0.05, end: 0);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.packageX,
              size: 40,
              color: Color(0xFF0284C7),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No Packages in $_selectedLevel',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap "+ New RP Package" to create one.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
