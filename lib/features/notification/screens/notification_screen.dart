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

/// Notification Screen - FinTech Animated, Filterable & Interactive Hub
class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  String _selectedFilter = 'All'; // 'All', 'Unread', 'Earnings', 'System'

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

    return Scaffold(
      body: AnimatedAmbientBackground(
        child: Column(
          children: [
            // 1. Royal FinTech Curved Header
            _buildHeader(
              context,
              unreadCount,
              notifications.isNotEmpty,
              isDark,
            ),

            // 2. Animated Category Filter Chips
            _buildFilterBar(notifications, unreadCount, isDark),

            // 3. Notification List or Empty State
            Expanded(
              child: filteredNotifications.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
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
    );
  }

  /// Royal FinTech Curved Header
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button + Title
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(9),
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
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Notifications',
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              if (unreadCount > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFEF4444),
                                        Color(0xFFDC2626),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
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
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            'Real-time transaction & reward alerts',
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Actions: Mark All Read & Clear All
                  if (hasNotifications)
                    Row(
                      children: [
                        // Mark all read button
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
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    LucideIcons.checkCheck,
                                    size: 13,
                                    color: Color(0xFF86EFAC),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Read all',
                                    style: GoogleFonts.spaceGrotesk(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(width: 6),

                        // Clear all button
                        GestureDetector(
                          onTap: () => _confirmClearAll(context),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.trash2,
                              size: 15,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Filter Chips Bar
  Widget _buildFilterBar(
    List<NotificationModel> allItems,
    int unreadCount,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildFilterChip('All', allItems.length, isDark),
            const SizedBox(width: 8),
            _buildFilterChip('Unread', unreadCount, isDark, isHighlight: true),
            const SizedBox(width: 8),
            _buildFilterChip('Earnings', null, isDark),
            const SizedBox(width: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0284C7)
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
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
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569)),
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : (isHighlight
                            ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                            : const Color(0xFF0284C7).withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10.5,
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

  /// Notification Card with dismissible action & tap dialog
  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel item,
    int index,
    bool isDark,
  ) {
    final typeConfig = _getTypeConfig(item.type);

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
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
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
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? (item.isRead
                          ? const Color(0xFF0F1A30)
                          : const Color(0xFF132448))
                    : (item.isRead ? Colors.white : const Color(0xFFF0F9FF)),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: item.isRead
                      ? (isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFE2E8F0))
                      : (isDark
                            ? const Color(0xFF38BDF8).withValues(alpha: 0.45)
                            : const Color(0xFF0284C7).withValues(alpha: 0.35)),
                  width: item.isRead ? 1.0 : 1.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.isRead
                        ? Colors.black.withValues(alpha: isDark ? 0.2 : 0.04)
                        : const Color(0xFF0284C7)
                              .withValues(alpha: isDark ? 0.25 : 0.12),
                    blurRadius: item.isRead ? 8 : 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Left Accent indicator bar for unread
                  if (!item.isRead)
                    Positioned(
                      left: 0,
                      top: 12,
                      bottom: 12,
                      child: Container(
                        width: 3.5,
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
                        // Category Icon with glow
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
                                color: typeConfig.gradientColors.first
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
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

                        // Title, message preview, timestamp, amount
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
                                        fontSize: 14,
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
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              Text(
                                item.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF475569),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Bottom metadata row (Tag, Amount, Read status)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Category Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: typeConfig.gradientColors.first
                                          .withValues(
                                            alpha: isDark ? 0.22 : 0.12,
                                          ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      typeConfig.label.toUpperCase(),
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: typeConfig.gradientColors.first,
                                      ),
                                    ),
                                  ),

                                  // Amount Pill if available
                                  if (item.amount != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: const Color(0xFF10B981)
                                              .withValues(alpha: 0.35),
                                        ),
                                      ),
                                      child: Text(
                                        '+₹${item.amount!.toStringAsFixed(2)}',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF10B981),
                                        ),
                                      ),
                                    )
                                  else if (!item.isRead)
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF0284C7),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Tap to view',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF0284C7),
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
        .fadeIn(delay: (index * 45).ms, duration: 350.ms)
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

  /// Full Notification Modal Dialog ("ek model bhi banana ki jab user kisi notification pe click kare to usse full notification show ho")
  void _showFullNotificationModal(
    BuildContext context,
    NotificationModel item,
    _NotificationTypeConfig typeConfig,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF142347),
                      const Color(0xFF0A1428),
                      const Color(0xFF101E3D),
                    ]
                  : [
                      const Color(0xFFE2F0FD),
                      const Color(0xFFEBF5FE),
                      const Color(0xFFF8FAFC),
                    ],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF38BDF8).withValues(alpha: 0.45)
                  : const Color(0xFF0284C7).withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7)
                    .withValues(alpha: isDark ? 0.40 : 0.20),
                blurRadius: 26,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Category badge, Icon & Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: typeConfig.gradientColors,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: typeConfig.gradientColors.first.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          typeConfig.icon,
                          size: 18,
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
                          color: typeConfig.gradientColors.first.withValues(
                            alpha: isDark ? 0.25 : 0.15,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: typeConfig.gradientColors.first.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        child: Text(
                          typeConfig.label.toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: typeConfig.gradientColors.first,
                          ),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(dialogCtx),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : const Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.x, size: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                item.title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 4),

              // Exact Timestamp
              Row(
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: 12,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDetailedDate(item.timestamp),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Highlight Box if Amount is present
              if (item.amount != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981)
                        .withValues(alpha: isDark ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF10B981)
                          .withValues(alpha: isDark ? 0.35 : 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.sparkles,
                            size: 15,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Credited Amount',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFF6EE7B7)
                                  : const Color(0xFF065F46),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '+₹${item.amount!.toStringAsFixed(2)}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Full Detailed Notification Message Body
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E293B)
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

                  // Route action button or Got It
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(dialogCtx);
                        if (item.actionRoute != null) {
                          context.push(item.actionRoute!);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
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
                  ),
                ],
              ),
            ],
          ),
        ),
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

  _NotificationTypeConfig _getTypeConfig(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return _NotificationTypeConfig(
          label: 'Order Return',
          icon: LucideIcons.circleDollarSign,
          gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
        );
      case NotificationType.rebate:
        return _NotificationTypeConfig(
          label: 'Team Rebate',
          icon: LucideIcons.users,
          gradientColors: const [Color(0xFFEF4444), Color(0xFFF43F5E)],
        );
      case NotificationType.reward:
        return _NotificationTypeConfig(
          label: 'Special Bonus',
          icon: LucideIcons.gift,
          gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
        );
      case NotificationType.security:
        return _NotificationTypeConfig(
          label: 'Security Alert',
          icon: LucideIcons.shieldCheck,
          gradientColors: const [Color(0xFF06B6D4), Color(0xFF0D9488)],
        );
      case NotificationType.system:
        return _NotificationTypeConfig(
          label: 'Platform Update',
          icon: LucideIcons.bell,
          gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
        );
    }
  }
}

class _NotificationTypeConfig {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;

  _NotificationTypeConfig({
    required this.label,
    required this.icon,
    required this.gradientColors,
  });
}
