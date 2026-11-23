import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/currency_formatter.dart';

class TeamMemberItem {
  final int id;
  final String maskedMobile;
  final String inviteCode;
  final String tier;
  final String commissionPercent;
  final double tradeVolume;
  final double commissionEarned;
  final String joinedAt;

  TeamMemberItem({
    required this.id,
    required this.maskedMobile,
    required this.inviteCode,
    required this.tier,
    required this.commissionPercent,
    required this.tradeVolume,
    required this.commissionEarned,
    required this.joinedAt,
  });

  factory TeamMemberItem.fromJson(Map<String, dynamic> json) {
    return TeamMemberItem(
      id: json['id'] as int? ?? 0,
      maskedMobile: json['maskedMobile'] as String? ?? '98****1234',
      inviteCode: json['inviteCode'] as String? ?? '',
      tier: json['tier'] as String? ?? 'L1',
      commissionPercent: json['commissionPercent'] as String? ?? '5%',
      tradeVolume: (json['tradeVolume'] as num?)?.toDouble() ?? 0.0,
      commissionEarned: (json['commissionEarned'] as num?)?.toDouble() ?? 0.0,
      joinedAt: json['joinedAt'] as String? ?? '',
    );
  }
}

class TeamMemberListSheet extends ConsumerStatefulWidget {
  final String tier;
  final String title;
  final Color accentColor;

  const TeamMemberListSheet({
    super.key,
    required this.tier,
    required this.title,
    required this.accentColor,
  });

  static void show(
    BuildContext context, {
    required String tier,
    required String title,
    required Color accentColor,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TeamMemberListSheet(
        tier: tier,
        title: title,
        accentColor: accentColor,
      ),
    );
  }

  @override
  ConsumerState<TeamMemberListSheet> createState() => _TeamMemberListSheetState();
}

class _TeamMemberListSheetState extends ConsumerState<TeamMemberListSheet> {
  bool _isLoading = true;
  List<TeamMemberItem> _members = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final res = await client.get(
        ApiEndpoints.teamMembers,
        queryParameters: {'tier': widget.tier},
      );

      if (res.success && res.data is List) {
        final list = (res.data as List)
            .map((item) => TeamMemberItem.fromJson(item as Map<String, dynamic>))
            .toList();
        setState(() {
          _members = list;
          _isLoading = false;
        });
      } else {
        setState(() {
          _members = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load tier members. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(LucideIcons.users, size: 18, color: widget.accentColor),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${widget.tier} Referral Directory',
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(LucideIcons.x, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                  padding: const EdgeInsets.all(6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Member List Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(color: Colors.redAccent),
                        ),
                      )
                    : _members.isEmpty
                        ? _buildEmptyState(isDark)
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _members.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final m = _members[index];
                              return _buildMemberCard(m, isDark);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.userX,
            size: 42,
            color: isDark ? Colors.white24 : const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 10),
          Text(
            'No ${widget.tier} Members Yet',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Share your invite code to start earning rebates!',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(TeamMemberItem m, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: widget.accentColor.withValues(alpha: 0.2),
                child: Text(
                  widget.tier,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: widget.accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.maskedMobile,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Code: ${m.inviteCode}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${CurrencyFormatter.format(m.commissionEarned)}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF10B981),
                ),
              ),
              Text(
                'Vol: ${CurrencyFormatter.format(m.tradeVolume)}',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  color: isDark ? Colors.white54 : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0);
  }
}
