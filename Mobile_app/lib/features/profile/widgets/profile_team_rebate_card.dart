import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/referral_provider.dart';

class ProfileTeamRebateCard extends StatelessWidget {
  final TeamOverview team;
  final int totalRebateYield;
  final bool isDark;

  const ProfileTeamRebateCard({
    super.key,
    required this.team,
    required this.totalRebateYield,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2C1118),
                  const Color(0xFF1E0A10),
                  const Color(0xFF36151E),
                ]
              : [
                  const Color(0xFFFFF1F2),
                  const Color(0xFFFFE4E6),
                  const Color(0xFFFFF7ED),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xFFF43F5E).withValues(alpha: 0.35)
              : const Color(0xFFF43F5E).withValues(alpha: 0.25),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF43F5E)
                .withValues(alpha: isDark ? 0.22 : 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Badge + Illustration
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFF43F5E)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444)
                                .withValues(alpha: 0.30),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.flame,
                            size: 11,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'MY TEAM REBATE',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Headline
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '3-LEVEL ',
                            style: GoogleFonts.spaceGrotesk(
                              color: const Color(0xFFEF4444),
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          TextSpan(
                            text: 'rebate mechanism',
                            style: GoogleFonts.spaceGrotesk(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Invite friends to earn up to $totalRebateYield% perpetual daily commissions on every trade.',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Glowing Team Avatar Container
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFF43F5E)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(LucideIcons.users, size: 28, color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3-Tier Commission Breakdown Pills
          Row(
            children: [
              _buildTierChip(
                'L1 Direct: ${team.level1Percent}',
                const Color(0xFFEF4444),
                isDark,
              ),
              const SizedBox(width: 6),
              _buildTierChip(
                'L2 Team: ${team.level2Percent}',
                const Color(0xFFF59E0B),
                isDark,
              ),
              const SizedBox(width: 6),
              _buildTierChip(
                'L3 Sub: ${team.level3Percent}',
                const Color(0xFF8B5CF6),
                isDark,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3D "View earnings >" Button
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/team');
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFEF4444),
                    Color(0xFFF43F5E),
                    Color(0xFFFB7185),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Team & Earnings',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    LucideIcons.arrowRight,
                    size: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierChip(String label, Color accentColor, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: isDark ? 0.20 : 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.30),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: isDark ? accentColor : accentColor.withValues(alpha: 0.95),
            ),
          ),
        ),
      ),
    );
  }
}
