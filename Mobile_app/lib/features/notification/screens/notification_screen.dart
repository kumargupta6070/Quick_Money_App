import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quick_money/core/providers/auth_provider.dart';
import 'package:quick_money/core/utils/custom_snackbar.dart';
import 'package:quick_money/features/admin/widgets/admin_broadcast_dialog.dart';
import 'package:quick_money/features/notification/models/notification_model.dart';
import 'package:quick_money/features/notification/providers/notification_provider.dart';
import 'package:quick_money/features/notification/widgets/notification_detail_modal.dart';
import 'package:quick_money/features/notification/widgets/notification_filter_bar.dart';
import 'package:quick_money/features/notification/widgets/notification_hero_header.dart';
import 'package:quick_money/features/notification/widgets/notification_item_card.dart';
import 'package:quick_money/features/notification/widgets/notification_overview_bar.dart';
import 'package:quick_money/features/notification/widgets/notification_search_bar.dart';
import 'package:quick_money/features/notification/widgets/notification_selection_bar.dart';
import 'package:quick_money/shared/widgets/animated_ambient_background.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final Set<String> _selectedIds = {};
  int _animSeed = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(notificationProvider.notifier).fetchNotifications(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  void _toggleSelectAll(List<NotificationModel> visibleList) {
    setState(() {
      if (_selectedIds.length == visibleList.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.clear();
        for (final item in visibleList) {
          _selectedIds.add(item.id);
        }
      }
    });
  }

  void _confirmDeleteSelected() {
    if (_selectedIds.isEmpty) return;
    final count = _selectedIds.length;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Selected Notifications',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Permanently delete $count selected notification${count > 1 ? 's' : ''}?',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              final idsToDelete = _selectedIds.toList();
              setState(() => _selectedIds.clear());
              ref
                  .read(notificationProvider.notifier)
                  .deleteMultipleNotifications(idsToDelete);
              CustomSnackBar.showSuccess(
                context: context,
                message: '$count notification${count > 1 ? 's' : ''} deleted.',
                icon: LucideIcons.trash2,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear All Notifications',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to remove all notifications? This action cannot be undone.',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              setState(() => _selectedIds.clear());
              ref.read(notificationProvider.notifier).clearAll();
              CustomSnackBar.showInfo(
                context: context,
                message: 'All notifications cleared.',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Clear All'),
          ),
        ],
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0284C7).withValues(alpha: 0.20),
                    const Color(0xFF2563EB).withValues(alpha: 0.08),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                ),
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.bellOff,
                  size: 36,
                  color: Color(0xFF0284C7),
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.05, 1.05),
                  duration: 1200.ms,
                ),
            const SizedBox(height: 18),
            Text(
              _searchQuery.isNotEmpty ? 'No Matching Notifications' : 'No Notifications',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No notifications match "$_searchQuery". Try searching a different keyword.'
                  : 'You are completely caught up! New order matching, rebate, and system announcements will show up here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final authState = ref.watch(authProvider);
    final isSuperAdmin = authState.isAdmin || authState.role == 'admin';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredNotifications = notifications.where((n) {
      if (_selectedFilter == 'Unread' && n.isRead) return false;
      if (_selectedFilter == 'Earnings') {
        final isEarning = n.type == NotificationType.order ||
            n.type == NotificationType.rebate ||
            n.type == NotificationType.reward;
        if (!isEarning) return false;
      }
      if (_selectedFilter == 'System') {
        final isSystem = n.type == NotificationType.security ||
            n.type == NotificationType.system;
        if (!isSystem) return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = n.title.toLowerCase().contains(q);
        final matchMsg = n.message.toLowerCase().contains(q);
        final matchDetail = n.detailedMessage.toLowerCase().contains(q);
        if (!matchTitle && !matchMsg && !matchDetail) return false;
      }
      return true;
    }).toList();

    final totalEarnings = notifications.fold<double>(
      0.0,
      (sum, item) => sum + (item.amount ?? 0.0),
    );

    return Scaffold(
      floatingActionButton: isSuperAdmin && !_isSelectionMode
          ? FloatingActionButton.extended(
              onPressed: () {
                HapticFeedback.lightImpact();
                showDialog(
                  context: context,
                  builder: (ctx) => AdminBroadcastDialog(isDark: isDark),
                );
              },
              backgroundColor: const Color(0xFF8B5CF6),
              icon: const Icon(LucideIcons.megaphone, color: Colors.white, size: 20),
              label: Text(
                'Announce Broadcast',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack)
          : null,
      body: AnimatedAmbientBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            setState(() => _animSeed++);
            await ref.read(notificationProvider.notifier).fetchNotifications();
          },
          child: Column(
            children: [
              // 1. Royal FinTech Curved Header
              NotificationHeroHeader(
                unreadCount: unreadCount,
                hasNotifications: notifications.isNotEmpty,
                isDark: isDark,
                onMarkAllRead: () {
                  ref.read(notificationProvider.notifier).markAllAsRead();
                  CustomSnackBar.showSuccess(
                    context: context,
                    message: 'All notifications marked as read.',
                    icon: LucideIcons.checkCheck,
                  );
                },
                onClearAll: () => _confirmClearAll(context),
              )
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: -0.05, end: 0, curve: Curves.easeOutCubic),

              // Multi-select Action Bar (when active)
              if (_isSelectionMode)
                NotificationSelectionBar(
                  selectedCount: _selectedIds.length,
                  totalCount: filteredNotifications.length,
                  onToggleSelectAll: () => _toggleSelectAll(filteredNotifications),
                  onDeleteSelected: _confirmDeleteSelected,
                  onCancel: () => setState(() => _selectedIds.clear()),
                  isDark: isDark,
                ),

              // 2. Overview Stats Strip (hide when in selection mode to save space)
              if (!_isSelectionMode)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: NotificationOverviewBar(
                    totalCount: notifications.length,
                    unreadCount: unreadCount,
                    totalEarnings: totalEarnings,
                    isDark: isDark,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 60.ms, duration: 380.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      delay: 60.ms,
                      curve: Curves.easeOutCubic,
                    ),

              // 3. Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: NotificationSearchBar(
                  controller: _searchController,
                  isDark: isDark,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  onClear: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              ),

              // 4. Filter Chips Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: NotificationFilterBar(
                  allItems: notifications,
                  unreadCount: unreadCount,
                  selectedFilter: _selectedFilter,
                  onFilterSelected: (f) => setState(() => _selectedFilter = f),
                  isDark: isDark,
                ),
              ),

              const SizedBox(height: 10),

              // 5. Notification List or Empty State
              Expanded(
                child: filteredNotifications.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        key: ValueKey(
                          'notif_list_${_animSeed}_${_selectedFilter}_$_searchQuery',
                        ),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 36),
                        itemCount: filteredNotifications.length,
                        itemBuilder: (context, index) {
                          final item = filteredNotifications[index];
                          final isSelected = _selectedIds.contains(item.id);

                          return NotificationItemCard(
                            item: item,
                            index: index,
                            isDark: isDark,
                            isSelected: isSelected,
                            isSelectionMode: _isSelectionMode,
                            onLongPress: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedIds.remove(item.id);
                                } else {
                                  _selectedIds.add(item.id);
                                }
                              });
                            },
                            onTap: () {
                              if (_isSelectionMode) {
                                setState(() {
                                  if (isSelected) {
                                    _selectedIds.remove(item.id);
                                  } else {
                                    _selectedIds.add(item.id);
                                  }
                                });
                              } else {
                                ref
                                    .read(notificationProvider.notifier)
                                    .markAsRead(item.id);
                                NotificationDetailModal.show(
                                  context,
                                  item: item,
                                  isDark: isDark,
                                );
                              }
                            },
                            onDismissed: () {
                              ref
                                  .read(notificationProvider.notifier)
                                  .deleteNotification(item.id);
                              CustomSnackBar.showInfo(
                                context: context,
                                message: 'Notification removed.',
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
}
