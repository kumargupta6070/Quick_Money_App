import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../widgets/admin_broadcast_button.dart';
import '../widgets/admin_financial_metrics_grid.dart';
import '../widgets/admin_hero_header.dart';
import '../widgets/admin_management_hub.dart';
import '../widgets/admin_pending_payout_alert.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProvider.notifier).fetchPlatformStats();
      ref.read(adminProvider.notifier).fetchPendingPayouts();
    });
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    CustomLoader.show(context, message: 'Refreshing live vault & metrics...');
    try {
      await Future.wait([
        ref.read(adminProvider.notifier).fetchPlatformStats(),
        ref.read(adminProvider.notifier).fetchPendingPayouts(),
      ]);
    } finally {
      if (mounted) {
        CustomLoader.hide(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adminState = ref.watch(adminProvider);
    final stats = adminState.stats;

    return Scaffold(
      body: AnimatedAmbientBackground(
        darkGradientColors: const [
          Color(0xFF070B18),
          Color(0xFF0C1733),
          Color(0xFF090D1E),
        ],
        lightGradientColors: const [
          Color(0xFFEEF4FF),
          Color(0xFFE0EDFF),
          Color(0xFFF8FAFC),
        ],
        primaryOrbColor: const Color(0xFF2563EB),
        secondaryOrbColor: const Color(0xFF00E5FF),
        tertiaryOrbColor: const Color(0xFFF59E0B),
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: const Color(0xFFF59E0B),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Royal SuperAdmin Header
                AdminHeroHeader(isDark: isDark, stats: stats)
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: -0.05, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 18),

                // 2. High-Priority Pending Payouts Alert Banner (if any)
                if (stats.pendingPayoutsCount > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AdminPendingPayoutAlert(stats: stats, isDark: isDark),
                  ).animate().fadeIn(delay: 70.ms).slideY(begin: 0.08, end: 0),

                if (stats.pendingPayoutsCount > 0) const SizedBox(height: 16),

                // 3. Platform Financial Health Metrics (Dual KPI Grid)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AdminFinancialMetricsGrid(stats: stats, isDark: isDark),
                ).animate().fadeIn(delay: 140.ms).slideY(begin: 0.08, end: 0),

                const SizedBox(height: 20),

                // 4. Quick Action Command Hub (Administrative Suites)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AdminManagementHub(stats: stats, isDark: isDark),
                ).animate().fadeIn(delay: 210.ms).slideY(begin: 0.08, end: 0),

                const SizedBox(height: 20),

                // 5. Broadcast Flash Alert Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AdminBroadcastButton(isDark: isDark),
                ).animate().fadeIn(delay: 280.ms).slideY(begin: 0.08, end: 0),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
