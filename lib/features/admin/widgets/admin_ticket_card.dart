import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AdminTicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final bool isDark;
  final VoidCallback onTap;

  const AdminTicketCard({
    super.key,
    required this.ticket,
    required this.isDark,
    required this.onTap,
  });

  String _formatRelativeTime(String? dateStr) {
    if (dateStr == null) return 'Recent';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return 'Recent';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final ticketNum = ticket['ticket_number']?.toString() ?? '#TKT';
    final userEmail = ticket['user_email']?.toString() ?? 'User';
    final userMobile = ticket['user_mobile']?.toString() ?? '';
    final category = ticket['category']?.toString() ?? 'Dispute';
    final subject = ticket['subject']?.toString() ?? 'No Subject';
    final message = ticket['message']?.toString() ?? '';
    final status = (ticket['status']?.toString().toLowerCase()) ?? 'open';
    final adminReply = ticket['admin_reply']?.toString() ?? '';
    final createdAt = ticket['created_at']?.toString();

    // Distinct Luxury Gradient Background & Accent Per Status
    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    List<Color> gradientColors;

    if (status == 'resolved') {
      statusColor = const Color(0xFF10B981);
      statusLabel = 'RESOLVED';
      statusIcon = LucideIcons.checkCheck;
      gradientColors = isDark
          ? const [Color(0xFF04241B), Color(0xFF0A3629)]
          : const [Color(0xFFF0FDF4), Color(0xFFDCFCE7)];
    } else if (status == 'replied') {
      statusColor = const Color(0xFF0284C7);
      statusLabel = 'REPLIED';
      statusIcon = LucideIcons.messageSquare;
      gradientColors = isDark
          ? const [Color(0xFF082238), Color(0xFF0F3252)]
          : const [Color(0xFFF0F9FF), Color(0xFFE0F2FE)];
    } else {
      statusColor = const Color(0xFFF59E0B);
      statusLabel = 'OPEN';
      statusIcon = LucideIcons.alertCircle;
      gradientColors = isDark
          ? const [Color(0xFF261503), Color(0xFF381F04)]
          : const [Color(0xFFFFFBEB), Color(0xFFFEF3C7)];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: statusColor.withValues(alpha: isDark ? 0.45 : 0.35),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: isDark ? 0.16 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Ticket Number & Status Pill (Guaranteed zero-overflow)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ticketNum,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 11, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Query Box (Subject & Message Preview)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.35 : 0.65),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                // Official Admin Resolution Box (if answered)
                if (adminReply.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? const [Color(0xFF063327), Color(0xFF032219)]
                            : const [Color(0xFFE8FDF3), Color(0xFFD1FAE5)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF10B981),
                          ),
                          child: const Icon(LucideIcons.check, size: 10, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Official Admin Resolution',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF10B981),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                adminReply,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Bottom Meta: User identity + Action button (Zero overflow)
                Row(
                  children: [
                    Icon(
                      LucideIcons.user,
                      size: 13,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '$userEmail${userMobile.isNotEmpty ? ' ($userMobile)' : ''} • ${_formatRelativeTime(createdAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                        ),
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            status == 'resolved' ? LucideIcons.fileCheck2 : LucideIcons.messageSquarePlus,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status == 'resolved' ? 'View / Edit' : 'Solve & Reply',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.05, end: 0, duration: 250.ms, curve: Curves.easeOutCubic);
  }
}
