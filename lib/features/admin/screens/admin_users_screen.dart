import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../widgets/admin_screen_hero_header.dart';
import '../widgets/admin_user_card.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'ALL';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProvider.notifier).fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    HapticFeedback.lightImpact();
    ref.read(adminProvider.notifier).fetchUsers(
          query: _searchController.text.trim(),
          status: _selectedStatus,
        );
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await ref.read(adminProvider.notifier).fetchUsers(
          query: _searchController.text.trim(),
          status: _selectedStatus,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adminState = ref.watch(adminProvider);
    final users = adminState.users;

    return Scaffold(
      body: AnimatedAmbientBackground(
        child: Column(
          children: [
            // 1. Signature Royal FinTech Header with HomeHeader
            AdminScreenHeroHeader(
              title: 'User Directory & Risk',
              icon: LucideIcons.users,
              badgeText: '${users.length} Traders',
              badgeColor: const Color(0xFF38BDF8),
            ),

            // 2. Search Box & Filter Chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _triggerSearch(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by Mobile, Email, Invite Code...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        LucideIcons.search,
                        size: 18,
                        color: Color(0xFF38BDF8),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(LucideIcons.arrowRight, size: 18),
                        onPressed: _triggerSearch,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: ['ALL', 'active', 'banned'].map((st) {
                      final isSelected = _selectedStatus == st;
                      final label = st == 'ALL' ? 'All Traders' : st.toUpperCase();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedStatus = st);
                            _triggerSearch();
                          },
                          selectedColor: const Color(0xFF0284C7),
                          labelStyle: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : const Color(0xFF475569)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // 3. User Cards List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: const Color(0xFF38BDF8),
                child: users.isEmpty && !adminState.isLoading
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 40),
                        itemCount: users.length,
                        itemBuilder: (context, i) {
                          return AdminUserCard(
                            user: users[i],
                            isDark: isDark,
                          )
                              .animate(delay: Duration(milliseconds: 40 * i))
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
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.userX,
              size: 40,
              color: Color(0xFF38BDF8),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No Traders Found',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search query or filter chip.',
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
