import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';

/// Support Desk Console for Super Admin to respond to user tickets.
class AdminSupportDeskDialog extends ConsumerStatefulWidget {
  final bool isDark;

  const AdminSupportDeskDialog({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminSupportDeskDialog(isDark: isDark),
    );
  }

  @override
  ConsumerState<AdminSupportDeskDialog> createState() =>
      _AdminSupportDeskDialogState();
}

class _AdminSupportDeskDialogState
    extends ConsumerState<AdminSupportDeskDialog> {
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final list = await ref.read(adminProvider.notifier).fetchSupportTickets();
    if (mounted) {
      setState(() {
        _tickets = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _replyTicket(int ticketId, String reply) async {
    HapticFeedback.mediumImpact();
    CustomLoader.show(context, message: 'Submitting response to trader...');

    final ok = await ref
        .read(adminProvider.notifier)
        .replySupportTicket(ticketId, reply);

    if (!mounted) return;
    CustomLoader.hide(context);

    if (ok) {
      CustomSnackBar.showTopSuccess(
        context: context,
        message: 'Response delivered to user notification feed!',
        icon: LucideIcons.send,
      );
      _loadTickets();
    }
  }

  void _showReplyModal(int ticketId, String subject) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        content: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDark
                  ? const [Color(0xFF0F1E36), Color(0xFF081220)]
                  : const [Colors.white, Color(0xFFF0F9FF)],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.45), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF2563EB)]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.send, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Reply: $subject',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                maxLines: 4,
                style: GoogleFonts.inter(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Enter official admin response...',
                  filled: true,
                  fillColor: widget.isDark ? const Color(0xFF0A1220) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (controller.text.trim().isNotEmpty) {
                          _replyTicket(ticketId, controller.text.trim());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Send Reply', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack, duration: 250.ms).fade(),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final id = (ticket['id'] as num?)?.toInt() ?? 0;
    final numStr = ticket['ticket_number']?.toString() ?? '#$id';
    final email = ticket['user_email']?.toString() ?? 'User';
    final category = ticket['category']?.toString() ?? 'General';
    final subject = ticket['subject']?.toString() ?? '';
    final message = ticket['message']?.toString() ?? '';
    final status = ticket['status']?.toString() ?? 'open';
    final reply = ticket['admin_reply']?.toString();

    final isResolved = status == 'resolved';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$numStr • $category',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0284C7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isResolved
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isResolved ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subject,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'From: $email',
            style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF64748B)),
          ),
          if (reply != null && reply.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Admin Response: $reply',
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF10B981)),
              ),
            ),
          ] else ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _showReplyModal(id, subject),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                icon: const Icon(LucideIcons.messageSquare, size: 14),
                label: const Text('Reply & Resolve', style: TextStyle(fontSize: 11)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: widget.isDark
              ? const [Color(0xFF0C192E), Color(0xFF070E1A)]
              : const [Colors.white, Color(0xFFF0F9FF)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: const Color(0xFF0284C7).withValues(alpha: 0.4), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 4.5,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF64748B),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(LucideIcons.headset, color: Color(0xFF0284C7)),
                const SizedBox(width: 10),
                Text(
                  'Trader Support Desk',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tickets.isEmpty
                    ? Center(
                        child: Text(
                          'No support tickets received.',
                          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _tickets.length,
                        itemBuilder: (_, i) => _buildTicketCard(_tickets[i]),
                      ),
          ),
        ],
      ),
    );
  }
}
