import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AdminHelpdeskReplyDialog extends StatefulWidget {
  final Map<String, dynamic> ticket;
  final bool isDark;
  final Future<void> Function(int ticketId, String reply, String status) onSendSolution;

  const AdminHelpdeskReplyDialog({
    super.key,
    required this.ticket,
    required this.isDark,
    required this.onSendSolution,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> ticket,
    required bool isDark,
    required Future<void> Function(int ticketId, String reply, String status) onSendSolution,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AdminHelpdeskReplyDialog(
        ticket: ticket,
        isDark: isDark,
        onSendSolution: onSendSolution,
      ),
    );
  }

  @override
  State<AdminHelpdeskReplyDialog> createState() => _AdminHelpdeskReplyDialogState();
}

class _AdminHelpdeskReplyDialogState extends State<AdminHelpdeskReplyDialog> {
  final TextEditingController _replyController = TextEditingController();
  String _selectedStatus = 'resolved';

  final List<String> _quickMacros = [
    '✅ Deposit Verified: Bank UTR matched and balance credited to your vault.',
    '⚡ Payout Settled: PhonePe return transfer has been completed via NPCI.',
    '🔄 System Synced: Wallet ledger refreshed, please reload your dashboard.',
    '⚠️ Invalid UTR: Please provide valid 12-digit bank reference number.',
  ];

  @override
  void initState() {
    super.initState();
    final existingReply = widget.ticket['admin_reply']?.toString() ?? '';
    if (existingReply.isNotEmpty) {
      _replyController.text = existingReply;
    }
    final existingStatus = widget.ticket['status']?.toString().toLowerCase() ?? 'resolved';
    if (existingStatus == 'open' || existingStatus == 'replied' || existingStatus == 'resolved') {
      _selectedStatus = existingStatus == 'open' ? 'resolved' : existingStatus;
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketId = int.tryParse(widget.ticket['id']?.toString() ?? '0') ?? 0;
    final ticketNum = widget.ticket['ticket_number']?.toString() ?? '#TKT-$ticketId';
    final userEmail = widget.ticket['user_email']?.toString() ?? 'Trader';
    final subject = widget.ticket['subject']?.toString() ?? 'Inquiry';
    final message = widget.ticket['message']?.toString() ?? 'No details provided.';
    final category = widget.ticket['category']?.toString() ?? 'General Dispute';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isDark
                ? const [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF0D1527)]
                : const [Colors.white, Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(LucideIcons.headset, color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Helpdesk Solution Desk',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          '$ticketNum • $userEmail',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (widget.isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.x,
                        size: 16,
                        color: widget.isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // User Issue In-Depth Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? const Color(0xFF0B132B).withValues(alpha: 0.8)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(LucideIcons.helpCircle, size: 14, color: Color(0xFF94A3B8)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subject,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: widget.isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Quick Preset Solution Macros
              Text(
                'QUICK PRESET SOLUTIONS (1-TAP AUTOFILL)',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _quickMacros.map((macro) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _replyController.text = macro;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        macro.split(':').first,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: widget.isDark ? const Color(0xFFDDD6FE) : const Color(0xFF6D28D9),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              // Solution Composer Field
              Text(
                'OFFICIAL RESPONSE & SOLUTION',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF090F1E) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                  ),
                ),
                child: TextField(
                  controller: _replyController,
                  maxLines: 4,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12),
                    border: InputBorder.none,
                    hintText: 'Type clear resolution instructions for trader...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 12,
                      color: widget.isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Status Selector (Zero overflow on all mobile screens)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Ticket Status:',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: widget.isDark ? Colors.white70 : const Color(0xFF334155),
                    ),
                  ),
                  ChoiceChip(
                    avatar: _selectedStatus == 'resolved'
                        ? const Icon(LucideIcons.check, size: 13, color: Colors.white)
                        : null,
                    label: const Text('Resolved'),
                    selected: _selectedStatus == 'resolved',
                    onSelected: (val) {
                      if (val) setState(() => _selectedStatus = 'resolved');
                    },
                    selectedColor: const Color(0xFF10B981),
                    backgroundColor: (widget.isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                    labelStyle: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _selectedStatus == 'resolved' ? Colors.white : const Color(0xFF10B981),
                    ),
                  ),
                  ChoiceChip(
                    avatar: _selectedStatus == 'replied'
                        ? const Icon(LucideIcons.messageSquare, size: 12, color: Colors.white)
                        : null,
                    label: const Text('Replied (Pending)'),
                    selected: _selectedStatus == 'replied',
                    onSelected: (val) {
                      if (val) setState(() => _selectedStatus = 'replied');
                    },
                    selectedColor: const Color(0xFF0284C7),
                    backgroundColor: (widget.isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                    labelStyle: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _selectedStatus == 'replied' ? Colors.white : const Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Send Action Button
              ElevatedButton.icon(
                onPressed: () {
                  final reply = _replyController.text.trim();
                  if (reply.isEmpty) return;
                  Navigator.pop(context);
                  widget.onSendSolution(ticketId, reply, _selectedStatus);
                },
                icon: const Icon(LucideIcons.send, size: 16, color: Colors.white),
                label: Text(
                  'Deliver Solution & Notify Trader',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF7C3AED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  shadowColor: const Color(0xFF7C3AED).withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 250.ms,
          curve: Curves.easeOutBack,
        );
  }
}
