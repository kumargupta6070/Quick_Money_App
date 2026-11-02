import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';

/// Notifications State Notifier
class NotificationNotifier extends Notifier<List<NotificationModel>> {
  static final List<NotificationModel> _initialNotifications = [
    NotificationModel(
      id: 'notif_1',
      title: 'Order Profit Credited',
      message: '₹24.80 profit credited for Order #QM-88391.',
      detailedMessage:
          'Your Order #QM-88391 for ₹620.00 has completed its matching cycle successfully. A brokerage reward of +₹24.80 has been instantly credited to your wallet balance. Once your daily earnings cross ₹100, funds will auto-transfer to your bound PhonePe account.',
      type: NotificationType.order,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
      amount: 24.80,
      actionRoute: '/daily-details',
      actionLabel: 'View in Daily Details',
    ),
    NotificationModel(
      id: 'notif_2',
      title: 'Level-1 Team Rebate Received',
      message: 'Subordinate user 98***442 completed an RP trade.',
      detailedMessage:
          'Congratulations! Your direct team partner (Tier 1) completed an RP order. Under the Quick Money 3-Level rebate mechanism (6% Direct), you have received a perpetual commission of +₹18.00 in your wallet.',
      type: NotificationType.rebate,
      timestamp: DateTime.now().subtract(const Duration(minutes: 42)),
      isRead: false,
      amount: 18.00,
      actionRoute: '/team',
      actionLabel: 'View Team Earnings',
    ),
    NotificationModel(
      id: 'notif_3',
      title: 'Newbie Starter Reward Unlocked',
      message: 'Welcome! Your Day 1 bonus of ₹50.00 is ready.',
      detailedMessage:
          'Welcome to Quick Money FinTech Platform! Your account is active and verified. Claim your starter bonus to accelerate your Level 1 RP trading experience.',
      type: NotificationType.reward,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
      amount: 50.00,
      actionRoute: '/newbie-rewards',
      actionLabel: 'Claim Starter Bonus',
    ),
    NotificationModel(
      id: 'notif_4',
      title: 'Payment APP Linked Successfully',
      message: 'PhonePe UPI ID bound for automatic return settlements.',
      detailedMessage:
          'Your PhonePe UPI ID (kumar****@ybl) has been securely verified and linked using 256-bit AES encryption. All your profits exceeding ₹100 will now auto-route directly to this UPI ID.',
      type: NotificationType.security,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      isRead: true,
      actionRoute: '/bind-payment',
      actionLabel: 'Manage Payment Methods',
    ),
    NotificationModel(
      id: 'notif_5',
      title: 'High Market Turnover Alert',
      message: 'Daily platform turnover reached ₹5,00,000+.',
      detailedMessage:
          'Trading volume on Quick Money has surged! Over 1,200 orders were matched within the last hour. Higher yield rates and faster order returns are currently live on Tiers L1 to L5.',
      type: NotificationType.system,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      actionRoute: '/buy-rp',
      actionLabel: 'Explore RP Orders',
    ),
    NotificationModel(
      id: 'notif_6',
      title: 'Security Login from Chrome Web',
      message: 'New browser session authorized via OTP verification.',
      detailedMessage:
          'A successful login was registered from Chrome Web on Windows OS. If this was you, no action is required. If you did not authorize this login, reset your password immediately.',
      type: NotificationType.security,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      actionRoute: '/account-security',
      actionLabel: 'Account Security Center',
    ),
  ];

  @override
  List<NotificationModel> build() {
    return _initialNotifications;
  }

  /// Mark single notification as read
  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  /// Mark single notification as unread
  void markAsUnread(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: false) else n,
    ];
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    state = [
      for (final n in state) n.copyWith(isRead: true),
    ];
  }

  /// Delete a single notification
  void deleteNotification(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  /// Clear all notifications
  void clearAll() {
    state = [];
  }
}

/// Provider for Notifications List
final notificationProvider =
    NotifierProvider<NotificationNotifier, List<NotificationModel>>(() {
  return NotificationNotifier();
});

/// Provider for Total Unread Notification Count
final unreadNotificationCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationProvider);
  return list.where((n) => !n.isRead).length;
});
