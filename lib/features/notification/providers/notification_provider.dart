import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/notification_model.dart';

/// Notifications State Notifier
class NotificationNotifier extends Notifier<List<NotificationModel>> {
  ApiClient get _apiClient => ref.read(apiClientProvider);

  @override
  List<NotificationModel> build() {
    Future.microtask(() => fetchNotifications());
    return const [];
  }

  /// Fetch live notifications from Backend API (GET /notifications)
  Future<void> fetchNotifications() async {
    try {
      if (ApiEndpoints.useMockData) return;
      final res = await _apiClient.get(ApiEndpoints.notifications);
      if (res.success && res.data is List) {
        final list = (res.data as List)
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
        state = list;
      }
    } catch (_) {
      // Non-blocking fallback
    }
  }

  /// Mark single notification as read
  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
    try {
      _apiClient.patch('${ApiEndpoints.notifications}/$id/read');
    } catch (_) {}
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
    state = [for (final n in state) n.copyWith(isRead: true)];
    try {
      _apiClient.post('${ApiEndpoints.notifications}/read-all');
    } catch (_) {}
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
