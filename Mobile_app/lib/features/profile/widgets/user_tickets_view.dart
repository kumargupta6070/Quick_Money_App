import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/custom_loader.dart';

class UserTicketsView extends ConsumerStatefulWidget {
  final bool isDark;

  const UserTicketsView({super.key, required this.isDark});

  @override
  ConsumerState<UserTicketsView> createState() => _UserTicketsViewState();
}

class _UserTicketsViewState extends ConsumerState<UserTicketsView> {
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyTickets();
  }

  Future<void> _fetchMyTickets() async {
    try {
      final client = ref.read(apiClientProvider);
      final res = await client.get(ApiEndpoints.userMyTickets);
      if (res.success && res.data is List) {
        if (mounted) {
          setState(() {
            _tickets = List<Map<String, dynamic>>.from(res.data);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CustomLoader.centered(message: 'Loading your tickets...'),
        ),
      );
    }

    if (_tickets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                ),
                child: const Icon(
                  LucideIcons.ticket,
                  color: Color(0xFF0284C7),
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No Tickets Raised Yet',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'When you raise an inquiry or dispute, track real-time resolution updates here.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _tickets.map((ticket) {
        final ticketNum = ticket['ticket_number']?.toString() ?? '#TKT';
        final category = ticket['category']?.toString() ?? 'General Dispute';
        final subject = ticket['subject']?.toString() ?? 'Inquiry';
        final message = ticket['message']?.toString() ?? '';
        final status = (ticket['status']?.toString().toLowerCase()) ?? 'open';
        final adminReply = ticket['admin_reply']?.toString() ?? '';
        final createdAt = ticket['created_at']?.toString();

        Color statusColor;
        String statusText;
        IconData statusIcon;
        List<Color> gradientColors;

        if (status == 'resolved') {
          statusColor = const Color(0xFF10B981);
          statusText = 'RESOLVED';
          statusIcon = LucideIcons.checkCheck;
          gradientColors = isDark
              ? const [Color(0xFF04241B), Color(0xFF0A3629)]
              : const [Color(0xFFF0FDF4), Color(0xFFDCFCE7)];
        } else if (status == 'replied') {
          statusColor = const Color(0xFF0284C7);
          statusText = 'REPLIED BY ADMIN';
          statusIcon = LucideIcons.messageSquare;
          gradientColors = isDark
              ? const [Color(0xFF082238), Color(0xFF0F3252)]
              : const [Color(0xFFF0F9FF), Color(0xFFE0F2FE)];
        } else {
          statusColor = const Color(0xFFF59E0B);
          statusText = 'IN REVIEW';
          statusIcon = LucideIcons.clock;
          gradientColors = isDark
              ? const [Color(0xFF261503), Color(0xFF381F04)]
              : const [Color(0xFFFFFBEB), Color(0xFFFEF3C7)];
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: statusColor.withValues(alpha: isDark ? 0.45 : 0.35),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: isDark ? 0.14 : 0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ticket Header: Number + Category + Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ticketNum,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0284C7),
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
                          statusText,
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

              // Query Content Box
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
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),

              // Admin Solution Box
              if (adminReply.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [Color(0xFF063327), Color(0xFF032219)]
                          : const [Color(0xFFE8FDF3), Color(0xFFD1FAE5)],
                    ),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3.5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF10B981),
                            ),
                            child: const Icon(LucideIcons.check, size: 10, color: Colors.white),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'ADMIN SOLUTION & RESPONSE',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                              color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        adminReply,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF064E3B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Date
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: 11,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Logged on ${_formatTime(createdAt)}',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
      }).toList(),
    );
  }
}
