import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

/// Notification Screen - Premium FinTech Animated & Responsive Experience
/// Features rich category-specific background colors, zero overflow, and interactive animated modal.
class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  String _selectedFilter = 'All'; // 'All', 'Unread', 'Earnings', 'System'
  int _animSeed = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(notificationProvider.notifier).fetchNotifications(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter list
    final filteredNotifications = notifications.where((n) {
      if (_selectedFilter == 'Unread') return !n.isRead;
      if (_selectedFilter == 'Earnings') {
        return n.type == NotificationType.order ||
            n.type == NotificationType.rebate ||
            n.type == NotificationType.reward;
      }
      if (_selectedFilter == 'System') {
        return n.type == NotificationType.security ||
            n.type == NotificationType.system;
      }
      return true;
    }).toList();

    // Calculate total earnings in notifications
    final totalEarnings = notifications.fold<double>(
      0.0,
      (sum, item) => sum + (item.amount ?? 0.0),
    );

    return Scaffold(
      body: AnimatedAmbientBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            setState(() => _animSeed++);
            await ref.read(notificationProvider.notifier).fetchNotifications();
          },
          child: Column(
            children: [
              // 1. Royal FinTech Curved Header (Zero Overflow Protected)
              _buildHeader(
                    context,
                    unreadCount,
                    notifications.isNotEmpty,
                    isDark,
                  )
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: -0.05, end: 0, curve: Curves.easeOutCubic),

              // 2. Overview Stats Strip (Colorful FinTech Card)
              Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: _buildOverviewStatsBar(
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

              const SizedBox(height: 8),

              // 3. Animated Filter Chips inside colorful container
              Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildFilterBar(notifications, unreadCount, isDark),
                  )
                  .animate()
                  .fadeIn(delay: 110.ms, duration: 380.ms)
                  .slideY(
                    begin: 0.08,
                    end: 0,
                    delay: 110.ms,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: 10),

              // 4. Notification List or Empty State
              Expanded(
                child: filteredNotifications.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        key: ValueKey(
                          'notif_list_${_animSeed}_$_selectedFilter',
                        ),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 36),
                        itemCount: filteredNotifications.length,
                        itemBuilder: (context, index) {
                          final item = filteredNotifications[index];
                          return _buildNotificationCard(
                            context,
                            item,
                            index,
                            isDark,
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

  /// Royal FinTech Header with Zero Overflow on any Screen Width
  Widget _buildHeader(
    BuildContext context,
    int unreadCount,
    bool hasNotifications,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF07112E),
                  const Color(0xFF0D256B),
                  const Color(0xFF133694),
                ]
              : [
                  const Color(0xFF091A4B),
                  const Color(0xFF11359A),
                  const Color(0xFF1849D6),
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D256B).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
          child: Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: const Icon(
                    LucideIcons.arrowLeft,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Title and Subtitle (Expanded to prevent any overflow)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Notifications',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEF4444)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Text(
                              '$unreadCount New',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Live transaction & profit alerts',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // Header Action Buttons (Read all & Clear all)
              if (hasNotifications)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (unreadCount > 0)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(notificationProvider.notifier)
                              .markAllAsRead();
                          CustomSnackBar.showSuccess(
                            context: context,
                            message: 'All notifications marked as read.',
                            icon: LucideIcons.checkCheck,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.checkCheck,
                                size: 12,
                                color: Color(0xFF86EFAC),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Read all',
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _confirmClearAll(context),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.trash2,
                          size: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Overview Stats Bar with Colorful FinTech Cards
  Widget _buildOverviewStatsBar({
    required int totalCount,
    required int unreadCount,
    required double totalEarnings,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF132247),
                  const Color(0xFF0C1630),
                  const Color(0xFF162854),
                ]
              : [
                  const Color(0xFFEFF8FF),
                  const Color(0xFFE0F2FE),
                  const Color(0xFFF0FDF4),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0xFF38BDF8).withValues(alpha: 0.35)
              : const Color(0xFF0284C7).withValues(alpha: 0.28),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7)
                .withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatPill(
            label: 'Total Alerts',
            value: '$totalCount',
            color: const Color(0xFF0284C7),
            icon: LucideIcons.bellRing,
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 26,
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFCBD5E1),
          ),
          _buildStatPill(
            label: 'Pending',
            value: '$unreadCount New',
            color: const Color(0xFFEF4444),
            icon: LucideIcons.sparkle,
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 26,
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFCBD5E1),
          ),
          _buildStatPill(
            label: 'Total Credited',
            value: '+₹${totalEarnings.toStringAsFixed(2)}',
            color: const Color(0xFF10B981),
            icon: LucideIcons.wallet,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  /// Filter Chips Bar inside colorful container
  Widget _buildFilterBar(
    List<NotificationModel> allItems,
    int unreadCount,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F1930)
            : const Color(0xFFF1F5F9).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1.1,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildFilterChip('All', allItems.length, isDark),
            const SizedBox(width: 6),
            _buildFilterChip('Unread', unreadCount, isDark, isHighlight: true),
            const SizedBox(width: 6),
            _buildFilterChip('Earnings', null, isDark),
            const SizedBox(width: 6),
            _buildFilterChip('System', null, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    int? count,
    bool isDark, {
    bool isHighlight = false,
  }) {
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0284C7)
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
            width: 1.1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569)),
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : (isHighlight
                            ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                            : const Color(0xFF0284C7).withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? Colors.white
                        : (isHighlight
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF0284C7)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Notification Card with Category-Specific Rich Colors & Animation
  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel item,
    int index,
    bool isDark,
  ) {
    final typeConfig = _getTypeConfig(item.type, isDark);

    return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            HapticFeedback.lightImpact();
            ref.read(notificationProvider.notifier).deleteNotification(item.id);
            CustomSnackBar.showInfo(
              context: context,
              message: 'Notification removed.',
            );
          },
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.centerRight,
            child: const Icon(
              LucideIcons.trash2,
              color: Colors.white,
              size: 22,
            ),
          ),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Mark read and open rich full notification modal dialog
              ref.read(notificationProvider.notifier).markAsRead(item.id);
              _showFullNotificationModal(context, item, typeConfig, isDark);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: typeConfig.cardGradient,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: typeConfig.borderColor,
                  width: item.isRead ? 1.1 : 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: typeConfig.accentColor.withValues(
                      alpha: isDark ? 0.22 : 0.12,
                    ),
                    blurRadius: item.isRead ? 8 : 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Left Accent indicator bar
                  Positioned(
                    left: 0,
                    top: 10,
                    bottom: 10,
                    child: Container(
                      width: item.isRead ? 3.0 : 4.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: typeConfig.gradientColors,
                        ),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category 3D Icon Container
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: typeConfig.gradientColors,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: typeConfig.accentColor.withValues(
                                  alpha: 0.38,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              typeConfig.icon,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      item.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14.5,
                                        fontWeight: item.isRead
                                            ? FontWeight.w700
                                            : FontWeight.w800,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatRelativeTime(item.timestamp),
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 5),

                              Text(
                                item.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? const Color(0xFFCBD5E1)
                                      : const Color(0xFF334155),
                                ),
                              ),

                              const SizedBox(height: 9),

                              // Metadata Row (Tag, Amount, Indicator)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Category Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: typeConfig.accentColor.withValues(
                                        alpha: isDark ? 0.28 : 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: typeConfig.accentColor
                                            .withValues(alpha: 0.35),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      typeConfig.label.toUpperCase(),
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? typeConfig.accentColor
                                            : typeConfig.gradientColors.first,
                                      ),
                                    ),
                                  ),

                                  // Amount Pill if available
                                  if (item.amount != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2.5,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF10B981),
                                            Color(0xFF059669),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF10B981)
                                                .withValues(alpha: 0.35),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '+₹${item.amount!.toStringAsFixed(2)}',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  else if (!item.isRead)
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: typeConfig.accentColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: typeConfig.accentColor,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Tap to view',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: typeConfig.accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (index * 45).ms, duration: 380.ms)
        .slideY(
          begin: 0.08,
          end: 0,
          delay: (index * 45).ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// Empty State Widget
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
              'No Notifications',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You are completely caught up! New order matching, rebate, and system announcements will show up here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Next-Level 3D FinTech Animated & Colorful Modal Dialog
  void _showFullNotificationModal(
    BuildContext context,
    NotificationModel item,
    _NotificationTypeConfig typeConfig,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) =>
          Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: typeConfig.modalGradient,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: typeConfig.accentColor.withValues(
                        alpha: isDark ? 0.55 : 0.45,
                      ),
                      width: 1.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: typeConfig.accentColor.withValues(
                          alpha: isDark ? 0.40 : 0.25,
                        ),
                        blurRadius: 32,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar: 3D Category Icon with Glowing Ring, Badge & Close
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Double glowing ring category icon
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: typeConfig.gradientColors,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: typeConfig.accentColor.withValues(
                                        alpha: 0.45,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  typeConfig.icon,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: typeConfig.accentColor.withValues(
                                    alpha: isDark ? 0.30 : 0.16,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: typeConfig.accentColor.withValues(
                                      alpha: 0.40,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  typeConfig.label.toUpperCase(),
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? typeConfig.accentColor
                                        : typeConfig.gradientColors.first,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(dialogCtx),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : const Color(0xFFE2E8F0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.x, size: 16),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Title
                      Text(
                        item.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Timestamp with green live indicator
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDetailedDate(item.timestamp),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Highlighted 3D Credited Amount Hero Box
                      if (item.amount != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF059669), Color(0xFF10B981)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    LucideIcons.sparkles,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CREDITED AMOUNT',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                          color: Colors.white.withValues(
                                            alpha: 0.85,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Instant Wallet Addition',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                '+₹${item.amount!.toStringAsFixed(2)}',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Full Detailed Notification Message Body
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.35)
                              : Colors.white.withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          item.detailedMessage,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFFE2E8F0)
                                : const Color(0xFF334155),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Security Guarantee Pill inside modal
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7)
                              .withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF0284C7)
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.shieldCheck,
                              size: 13,
                              color: Color(0xFF0284C7),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Verified & Protected under Quick Money FinTech Protocol.',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFF38BDF8)
                                      : const Color(0xFF0369A1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Action Buttons
                      Row(
                        children: [
                          // Mark as Unread Button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(notificationProvider.notifier)
                                    .markAsUnread(item.id);
                                Navigator.pop(dialogCtx);
                                CustomSnackBar.showInfo(
                                  context: context,
                                  message: 'Marked as unread.',
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF94A3B8),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Mark Unread',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Route Action Button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(dialogCtx);
                                if (item.actionRoute != null) {
                                  final route = item.actionRoute!;
                                  if (route == '/sell-rp' ||
                                      route == '/buy-rp' ||
                                      route == '/home' ||
                                      route == '/profile') {
                                    context.go(route);
                                  } else {
                                    context.push(route);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    typeConfig.gradientColors.first,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 3,
                                shadowColor: typeConfig.accentColor.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      item.actionLabel ?? 'Got It',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(LucideIcons.arrowRight, size: 14),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.88, 0.88),
                end: const Offset(1, 1),
                duration: 300.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 250.ms),
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

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}';
  }

  String _formatDetailedDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}, $hour:$minute $period';
  }

  _NotificationTypeConfig _getTypeConfig(NotificationType type, bool isDark) {
    switch (type) {
      case NotificationType.order:
        return _NotificationTypeConfig(
          label: 'Order Return',
          icon: LucideIcons.circleDollarSign,
          accentColor: const Color(0xFF10B981),
          borderColor: isDark
              ? const Color(0xFF10B981).withValues(alpha: 0.45)
              : const Color(0xFF10B981).withValues(alpha: 0.40),
          gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
          cardGradient: isDark
              ? const [Color(0xFF063E30), Color(0xFF02261E)]
              : const [Color(0xFFF0FDF4), Color(0xFFDCFCE7), Color(0xFFECFDF5)],
          modalGradient: isDark
              ? const [Color(0xFF0A3D2F), Color(0xFF042119)]
              : const [Color(0xFFE6FFFA), Color(0xFFD1FAE5), Color(0xFFF0FDF4)],
        );
      case NotificationType.rebate:
        return _NotificationTypeConfig(
          label: 'Team Rebate',
          icon: LucideIcons.users,
          accentColor: const Color(0xFFEF4444),
          borderColor: isDark
              ? const Color(0xFFF43F5E).withValues(alpha: 0.45)
              : const Color(0xFFF43F5E).withValues(alpha: 0.38),
          gradientColors: const [Color(0xFFEF4444), Color(0xFFF43F5E)],
          cardGradient: isDark
              ? const [Color(0xFF4C0A1A), Color(0xFF28030D)]
              : const [Color(0xFFFFF1F2), Color(0xFFFFE4E6), Color(0xFFFEF2F2)],
          modalGradient: isDark
              ? const [Color(0xFF450A19), Color(0xFF23030B)]
              : const [Color(0xFFFFF1F2), Color(0xFFFFE4E6), Color(0xFFFFF7ED)],
        );
      case NotificationType.reward:
        return _NotificationTypeConfig(
          label: 'Special Bonus',
          icon: LucideIcons.gift,
          accentColor: const Color(0xFFF59E0B),
          borderColor: isDark
              ? const Color(0xFFF59E0B).withValues(alpha: 0.45)
              : const Color(0xFFF59E0B).withValues(alpha: 0.40),
          gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
          cardGradient: isDark
              ? const [Color(0xFF451E06), Color(0xFF261003)]
              : const [Color(0xFFFFFBEB), Color(0xFFFEF3C7), Color(0xFFFFF7ED)],
          modalGradient: isDark
              ? const [Color(0xFF401C06), Color(0xFF200D02)]
              : const [Color(0xFFFFFBEB), Color(0xFFFEF3C7), Color(0xFFFFF1F2)],
        );
      case NotificationType.security:
        return _NotificationTypeConfig(
          label: 'Security Alert',
          icon: LucideIcons.shieldCheck,
          accentColor: const Color(0xFF06B6D4),
          borderColor: isDark
              ? const Color(0xFF06B6D4).withValues(alpha: 0.45)
              : const Color(0xFF06B6D4).withValues(alpha: 0.38),
          gradientColors: const [Color(0xFF06B6D4), Color(0xFF0D9488)],
          cardGradient: isDark
              ? const [Color(0xFF083344), Color(0xFF031E28)]
              : const [Color(0xFFECFEFF), Color(0xFFCFFAFE), Color(0xFFF0FDFA)],
          modalGradient: isDark
              ? const [Color(0xFF073040), Color(0xFF031A24)]
              : const [Color(0xFFECFEFF), Color(0xFFE0F2FE), Color(0xFFF0FDF4)],
        );
      case NotificationType.system:
        return _NotificationTypeConfig(
          label: 'Platform Update',
          icon: LucideIcons.bell,
          accentColor: const Color(0xFF8B5CF6),
          borderColor: isDark
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.45)
              : const Color(0xFF8B5CF6).withValues(alpha: 0.38),
          gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          cardGradient: isDark
              ? const [Color(0xFF2A1058), Color(0xFF160731)]
              : const [Color(0xFFFAF5FF), Color(0xFFEDE9FE), Color(0xFFF5F3FF)],
          modalGradient: isDark
              ? const [Color(0xFF250E4E), Color(0xFF13062B)]
              : const [Color(0xFFFAF5FF), Color(0xFFEDE9FE), Color(0xFFEFF6FF)],
        );
    }
  }
}

class _NotificationTypeConfig {
  final String label;
  final IconData icon;
  final Color accentColor;
  final Color borderColor;
  final List<Color> gradientColors;
  final List<Color> cardGradient;
  final List<Color> modalGradient;

  _NotificationTypeConfig({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.borderColor,
    required this.gradientColors,
    required this.cardGradient,
    required this.modalGradient,
  });
}
