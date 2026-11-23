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

        if (status == 'resolved') {
          statusColor = const Color(0xFF10B981);
          statusText = 'RESOLVED';
          statusIcon = LucideIcons.checkCheck;
        } else if (status == 'replied') {
          statusColor = const Color(0xFF0284C7);
          statusText = 'REPLIED BY ADMIN';
          statusIcon = LucideIcons.messageSquare;
        } else {
          statusColor = const Color(0xFFF59E0B);
          statusText = 'IN REVIEW';
          statusIcon = LucideIcons.clock;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: statusColor.withValues(alpha: isDark ? 0.40 : 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: isDark ? 0.12 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
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
                      color: const Color(0xFF0284C7).withValues(alpha: 0.15),
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
                    child: Text(
                      category,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
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

              // Subject
              Text(
                subject,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 4),

              // Message
              Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                ),
              ),

              // Admin Solution Box
              if (adminReply.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [Color(0xFF064E3B), Color(0xFF042F2E)]
                          : const [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.checkCircle2, size: 14, color: Color(0xFF10B981)),
                          const SizedBox(width: 6),
                          Text(
                            'ADMIN SOLUTION & RESPONSE',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
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
        ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.05, end: 0);
      }).toList(),
    );
  }
}
