import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../../shared/models/order_model.dart';
import '../../shared/models/admin_model.dart';

export '../../shared/models/admin_model.dart';

/// Combined Admin State
class AdminState {
  final bool isLoading;
  final AdminStats stats;
  final List<AdminPayoutItem> payouts;
  final List<OrderModel> packages;
  final List<AdminUserItem> users;
  final int totalUsersCount;
  final Map<String, String> settings;
  final String? errorMessage;

  const AdminState({
    this.isLoading = false,
    this.stats = AdminStats.empty,
    this.payouts = const [],
    this.packages = const [],
    this.users = const [],
    this.totalUsersCount = 0,
    this.settings = const {},
    this.errorMessage,
  });

  AdminState copyWith({
    bool? isLoading,
    AdminStats? stats,
    List<AdminPayoutItem>? payouts,
    List<OrderModel>? packages,
    List<AdminUserItem>? users,
    int? totalUsersCount,
    Map<String, String>? settings,
    String? errorMessage,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      payouts: payouts ?? this.payouts,
      packages: packages ?? this.packages,
      users: users ?? this.users,
      totalUsersCount: totalUsersCount ?? this.totalUsersCount,
      settings: settings ?? this.settings,
      errorMessage: errorMessage,
    );
  }
}

class AdminNotifier extends Notifier<AdminState> {
  ApiClient get _apiClient => ref.read(apiClientProvider);

  @override
  AdminState build() {
    return const AdminState();
  }

  /// 1. Fetch Platform Stats
  Future<void> fetchPlatformStats() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final res = await _apiClient.get(ApiEndpoints.adminStats);
      if (res.success && res.data != null) {
        final stats = AdminStats.fromJson(res.data as Map<String, dynamic>);
        state = state.copyWith(stats: stats, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: res.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// 2. Fetch Pending PhonePe Payouts
  Future<void> fetchPendingPayouts() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final res = await _apiClient.get(ApiEndpoints.adminPendingPayouts);
      if (res.success && res.data != null) {
        final list = (res.data as List<dynamic>)
            .map(
              (item) => AdminPayoutItem.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        state = state.copyWith(payouts: list, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: res.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// 3a. Settle a Payout with Bank UTR Reference
  Future<bool> settlePayout(int payoutId, String utrReference) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.adminSettlePayout(payoutId),
        data: {'utrReference': utrReference},
      );
      if (res.success) {
        state = state.copyWith(
          payouts: state.payouts.where((p) => p.id != payoutId).toList(),
        );
        fetchPlatformStats();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 3b. Reject a Payout and Refund User Balance
  Future<bool> rejectPayout(int payoutId) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.adminPayoutReject(payoutId),
      );
      if (res.success) {
        state = state.copyWith(
          payouts: state.payouts.where((p) => p.id != payoutId).toList(),
        );
        fetchPlatformStats();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 4. Fetch All RP Packages with Optional Level Filter
  Future<void> fetchPackages({String? level}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final lvl = level ?? 'ALL';
      final endpoint = lvl == 'ALL'
          ? ApiEndpoints.adminPackages
          : '${ApiEndpoints.adminPackages}?level=$lvl';
      final res = await _apiClient.get(endpoint);
      if (res.success && res.data != null) {
        final list = (res.data as List<dynamic>)
            .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
            .toList();
        state = state.copyWith(packages: list, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: res.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// 5. Create New RP Package
  Future<bool> createPackage({
    required double orderAmount,
    required int orderQuantity,
    required double reward,
    required double bonus,
    required String level,
    String status = 'active',
  }) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.adminPackages,
        data: {
          'order_amount': orderAmount,
          'order_quantity': orderQuantity,
          'reward': reward,
          'bonus': bonus,
          'level': level,
          'status': status,
        },
      );
      if (res.success) {
        fetchPackages();
        fetchPlatformStats();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 6. Update Existing Package
  Future<bool> updatePackage({
    required int id,
    double? orderAmount,
    int? orderQuantity,
    double? reward,
    double? bonus,
    String? level,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (orderAmount != null) data['order_amount'] = orderAmount;
      if (orderQuantity != null) data['order_quantity'] = orderQuantity;
      if (reward != null) data['reward'] = reward;
      if (bonus != null) data['bonus'] = bonus;
      if (level != null) data['level'] = level;
      if (status != null) data['status'] = status;

      final res = await _apiClient.put(
        ApiEndpoints.adminPackageDetail(id),
        data: data,
      );
      if (res.success) {
        fetchPackages();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 7. Delete Package
  Future<bool> deletePackage(int id) async {
    try {
      final res = await _apiClient.delete(ApiEndpoints.adminPackageDetail(id));
      if (res.success) {
        state = state.copyWith(
          packages: state.packages.where((p) => p.id != id).toList(),
        );
        fetchPlatformStats();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 8. Search Users
  Future<void> fetchUsers({String query = '', String status = 'ALL'}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final params = <String, String>{};
      if (query.isNotEmpty) params['query'] = query;
      if (status != 'ALL') params['status'] = status;

      final uri = Uri(
        path: ApiEndpoints.adminUsers,
        queryParameters: params.isNotEmpty ? params : null,
      ).toString();

      final res = await _apiClient.get(uri);
      if (res.success && res.data != null) {
        final dataMap = res.data as Map<String, dynamic>;
        final count = (dataMap['total'] as num?)?.toInt() ?? 0;
        final list = (dataMap['users'] as List<dynamic>)
            .map((item) => AdminUserItem.fromJson(item as Map<String, dynamic>))
            .toList();
        state = state.copyWith(
          users: list,
          totalUsersCount: count,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, errorMessage: res.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// 9. Update User Status (Freeze/Unfreeze)
  Future<bool> updateUserStatus(int userId, String status) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.adminUserStatus(userId),
        data: {'status': status},
      );
      if (res.success) {
        fetchUsers();
        fetchPlatformStats();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 10. Adjust User Balance (+/-)
  Future<bool> adjustUserBalance({
    required int userId,
    required double amount,
    required String type,
    required String reason,
  }) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.adminUserAdjustBalance(userId),
        data: {'amount': amount, 'type': type, 'reason': reason},
      );
      if (res.success) {
        fetchUsers();
        fetchPlatformStats();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 11. Fetch Platform Settings
  Future<void> fetchSettings() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final res = await _apiClient.get(ApiEndpoints.adminSettings);
      if (res.success && res.data != null) {
        final rawMap = res.data as Map<String, dynamic>;
        final map = <String, String>{};
        rawMap.forEach((k, v) => map[k] = v.toString());
        state = state.copyWith(settings: map, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: res.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// 12. Save Platform Settings
  Future<bool> saveSettings(Map<String, String> newSettings) async {
    try {
      final res = await _apiClient.put(
        ApiEndpoints.adminSettings,
        data: {'settings': newSettings},
      );
      if (res.success && res.data != null) {
        final rawMap = res.data as Map<String, dynamic>;
        final map = <String, String>{};
        rawMap.forEach((k, v) => map[k] = v.toString());
        state = state.copyWith(settings: map);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 13. Broadcast Flash Announcement
  Future<bool> broadcastAnnouncement({
    required String title,
    required String message,
  }) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.adminBroadcast,
        data: {'title': title, 'message': message, 'type': 'system'},
      );
      return res.success;
    } catch (_) {
      return false;
    }
  }
}

final adminProvider = NotifierProvider<AdminNotifier, AdminState>(
  AdminNotifier.new,
);
