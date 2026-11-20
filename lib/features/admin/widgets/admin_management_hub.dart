import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';

/// Quick Action Management Hub (4 Big Administrative Control Suites)
class AdminManagementHub extends StatelessWidget {
  final AdminStats stats;
  final bool isDark;

  const AdminManagementHub({
    super.key,
    required this.stats,
    required this.isDark,
  });

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required String badgeText,
    Color? badgeColor,
    required IconData icon,
    required List<Color> iconColors,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: iconColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: iconColors.first.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(icon, color: Colors.white, size: 21),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: (badgeColor ?? iconColors.first).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (badgeColor ?? iconColors.first).withValues(alpha: 0.40),
                  ),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeColor ?? iconColors.first,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'ADMINISTRATIVE CONTROL SUITES',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          title: 'RP Packages & Market Orders',
          subtitle: 'Create, edit amounts, rewards, bonuses & pause L1-L7 packages',
          badgeText: '${stats.activePackages} Active',
          icon: LucideIcons.packagePlus,
          iconColors: const [Color(0xFF0284C7), Color(0xFF2563EB)],
          onTap: () => context.push('/admin/orders'),
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          title: 'Payout Settlement Desk',
          subtitle: 'Verify PhonePe returns & settle payouts with live Bank UTR',
          badgeText: '${stats.pendingPayoutsCount} Pending',
          badgeColor: stats.pendingPayoutsCount > 0 ? const Color(0xFFE11D48) : const Color(0xFF10B981),
          icon: LucideIcons.banknote,
          iconColors: const [Color(0xFF059669), Color(0xFF10B981)],
          onTap: () => context.push('/admin/payouts'),
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          title: 'User Directory & Risk Control',
          subtitle: 'Search traders, freeze/unfreeze accounts & adjust balances',
          badgeText: '${stats.totalUsers} Users',
          icon: LucideIcons.users,
          iconColors: const [Color(0xFF7C3AED), Color(0xFF9333EA)],
          onTap: () => context.push('/admin/users'),
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          title: 'Platform Rules & Dynamic Rates',
          subtitle: 'Change yield rate (2.5%), referral rebates & auto-return threshold',
          badgeText: 'Live Config',
          icon: LucideIcons.sliders,
          iconColors: const [Color(0xFFD97706), Color(0xFFF59E0B)],
          onTap: () => context.push('/admin/settings'),
          isDark: isDark,
        ),
      ],
    );
  }
}
