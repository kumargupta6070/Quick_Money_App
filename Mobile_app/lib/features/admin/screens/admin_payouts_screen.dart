import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../widgets/admin_payout_card.dart';
import '../widgets/admin_screen_hero_header.dart';

class AdminPayoutsScreen extends ConsumerStatefulWidget {
  const AdminPayoutsScreen({super.key});

  @override
  ConsumerState<AdminPayoutsScreen> createState() => _AdminPayoutsScreenState();
}

class _AdminPayoutsScreenState extends ConsumerState<AdminPayoutsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProvider.notifier).fetchPendingPayouts();
    });
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    CustomLoader.show(context, message: 'Refreshing PhonePe payouts desk...');
    try {
      await ref.read(adminProvider.notifier).fetchPendingPayouts();
    } finally {
      if (mounted) CustomLoader.hide(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adminState = ref.watch(adminProvider);
    final payouts = adminState.payouts;

    return Scaffold(
      body: AnimatedAmbientBackground(
        darkGradientColors: const [
          Color(0xFF2D1402),
          Color(0xFF451A03),
          Color(0xFF1F0D01),
        ],
        lightGradientColors: const [
          Color(0xFFFFFBEB),
          Color(0xFFFEF3C7),
          Color(0xFFFFF7ED),
        ],
        primaryOrbColor: const Color(0xFFF59E0B),
        secondaryOrbColor: const Color(0xFFFB923C),
        tertiaryOrbColor: const Color(0xFFEAB308),
        child: Column(
          children: [
            // 1. Signature Royal FinTech Header with HomeHeader
            AdminScreenHeroHeader(
              title: 'Payout Settlement Desk',
              icon: LucideIcons.arrowDownToLine,
              badgeText: '${payouts.length} Pending',
              badgeColor: payouts.isNotEmpty
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF10B981),
            ),

            const SizedBox(height: 10),

            // 2. Pending Payouts List with Staggered Animations
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: const Color(0xFF10B981),
                child: payouts.isEmpty && !adminState.isLoading
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 40),
                        itemCount: payouts.length,
                        itemBuilder: (context, i) {
                          return AdminPayoutCard(
                            payout: payouts[i],
                            isDark: isDark,
                          )
                              .animate(delay: Duration(milliseconds: 50 * i))
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.shieldCheck,
              size: 44,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'All Payouts Settled!',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No pending PhonePe profit return requests at this time.',
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
