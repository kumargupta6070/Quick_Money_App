import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../widgets/admin_helpdesk_reply_dialog.dart';
import '../widgets/admin_ticket_card.dart';

class AdminHelpdeskScreen extends ConsumerStatefulWidget {
  const AdminHelpdeskScreen({super.key});

  @override
  ConsumerState<AdminHelpdeskScreen> createState() => _AdminHelpdeskScreenState();
}

class _AdminHelpdeskScreenState extends ConsumerState<AdminHelpdeskScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;
  String _statusFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets({bool showCustomLoader = false}) async {
    if (showCustomLoader) {
      CustomLoader.show(context, message: 'Refreshing live helpdesk tickets...');
    }
    try {
      final list = await ref.read(adminProvider.notifier).fetchSupportTickets();
      if (mounted) {
        setState(() {
          _tickets = list;
          _isLoading = false;
        });
      }
    } finally {
      if (showCustomLoader && mounted) {
        CustomLoader.hide(context);
      }
    }
  }

  Future<void> _submitReply(int ticketId, String reply, String status) async {
    HapticFeedback.mediumImpact();
    CustomLoader.show(context, message: 'Submitting solution to trader...');

    final ok = await ref
        .read(adminProvider.notifier)
        .replySupportTicket(ticketId, reply, status: status);

    if (!mounted) return;
    CustomLoader.hide(context);

    if (ok) {
      CustomSnackBar.showSuccess(
        context: context,
        message: 'Solution delivered! Trader notified in real-time.',
        icon: LucideIcons.send,
      );
      _loadTickets();
    } else {
      CustomSnackBar.showError(
        context: context,
        message: 'Failed to deliver solution. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final openCount = _tickets.where((t) => (t['status']?.toString().toLowerCase()) == 'open').length;
    final resolvedCount = _tickets.where((t) => (t['status']?.toString().toLowerCase()) == 'resolved').length;

    final filteredTickets = _tickets.where((t) {
      final status = (t['status']?.toString().toLowerCase()) ?? 'open';
      if (_statusFilter == 'Open' && status != 'open') return false;
      if (_statusFilter == 'Replied' && status != 'replied') return false;
      if (_statusFilter == 'Resolved' && status != 'resolved') return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final num = (t['ticket_number']?.toString() ?? '').toLowerCase();
        final email = (t['user_email']?.toString() ?? '').toLowerCase();
        final subj = (t['subject']?.toString() ?? '').toLowerCase();
        final msg = (t['message']?.toString() ?? '').toLowerCase();
        if (!num.contains(q) && !email.contains(q) && !subj.contains(q) && !msg.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    return Scaffold(
      body: AnimatedAmbientBackground(
        darkGradientColors: const [
          Color(0xFF090D24),
          Color(0xFF111E48),
          Color(0xFF080C1E),
        ],
        lightGradientColors: const [
          Color(0xFFF5F3FF),
          Color(0xFFEDE9FE),
          Color(0xFFF8FAFC),
        ],
        primaryOrbColor: const Color(0xFF7C3AED),
        secondaryOrbColor: const Color(0xFF0284C7),
        tertiaryOrbColor: const Color(0xFF10B981),
        child: RefreshIndicator(
          onRefresh: () => _loadTickets(showCustomLoader: true),
          color: const Color(0xFF8B5CF6),
          child: Column(
            children: [
              // 1. SuperAdmin Helpdesk Hero Header
              _buildHeader(context, isDark, openCount, resolvedCount),

              // 2. Search & Metric Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: _buildSearchBar(isDark),
              ),

              // 3. Status Filter Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildStatusFilterTabs(isDark),
              ),

              const SizedBox(height: 8),

              // 4. Ticket Feed or Empty State
              Expanded(
                child: _isLoading
                    ? Center(child: CustomLoader.centered(message: 'Loading live tickets...'))
                    : filteredTickets.isEmpty
                        ? _buildEmptyState(isDark)
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 40),
                            itemCount: filteredTickets.length,
                            itemBuilder: (context, index) {
                              final ticket = filteredTickets[index];
                              return AdminTicketCard(
                                ticket: ticket,
                                isDark: isDark,
                                onTap: () {
                                  AdminHelpdeskReplyDialog.show(
                                    context,
                                    ticket: ticket,
                                    isDark: isDark,
                                    onSendSolution: _submitReply,
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, int openCount, int resolvedCount) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4C1D95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.arrowLeft, size: 18, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HELPDESK RESOLUTION DESK',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Review trader disputes, send solutions & resolve issues',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFDDD6FE),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _loadTickets(showCustomLoader: true),
                icon: const Icon(LucideIcons.refreshCw, size: 18, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniMetric('Total', '${_tickets.length}', const Color(0xFF8B5CF6)),
              const SizedBox(width: 8),
              _buildMiniMetric('Open Issues', '$openCount', const Color(0xFFF59E0B), isAlert: openCount > 0),
              const SizedBox(width: 8),
              _buildMiniMetric('Resolved', '$resolvedCount', const Color(0xFF10B981)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, Color color, {bool isAlert = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: isAlert ? 0.7 : 0.3),
            width: isAlert ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFCBD5E1),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1.1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val.trim()),
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          border: InputBorder.none,
          prefixIcon: const Icon(LucideIcons.search, size: 17, color: Color(0xFF8B5CF6)),
          hintText: 'Search tickets by ID, email or keyword...',
          hintStyle: GoogleFonts.inter(
            fontSize: 12,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(LucideIcons.x, size: 15),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildStatusFilterTabs(bool isDark) {
    final filters = ['All', 'Open', 'Replied', 'Resolved'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = _statusFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => _statusFilter = f);
              },
              selectedColor: const Color(0xFF7C3AED),
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              labelStyle: GoogleFonts.spaceGrotesk(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF7C3AED)
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
              ),
              child: const Center(
                child: Icon(LucideIcons.checkCheck, size: 32, color: Color(0xFF8B5CF6)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Tickets Found',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No disputes match "$_searchQuery".'
                  : 'All trader questions and helpdesk inquiries are resolved!',
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
}
