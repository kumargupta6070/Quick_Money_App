import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../../shared/models/order_model.dart';

/// Admin Dashboard Metrics Model
class AdminStats {
  final int totalUsers;
  final int activeUsers;
  final int bannedUsers;
  final int totalOrders;
  final int activePackages;
  final int completedOrders;
  final double totalPlatformVolume;
  final double totalUserBalanceFloat;
  final int pendingPayoutsCount;
  final double totalPendingPayoutsAmount;
  final double totalPayoutsSettled;
  final String marketStatus;
  final String serverTime;

  const AdminStats({
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.bannedUsers = 0,
    this.totalOrders = 0,
    this.activePackages = 0,
    this.completedOrders = 0,
    this.totalPlatformVolume = 0.0,
    this.totalUserBalanceFloat = 0.0,
    this.pendingPayoutsCount = 0,
    this.totalPendingPayoutsAmount = 0.0,
    this.totalPayoutsSettled = 0.0,
    this.marketStatus = 'ONLINE',
    this.serverTime = '',
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    final ov = json['overview'] as Map<String, dynamic>? ?? {};
    return AdminStats(
      totalUsers: (ov['totalUsers'] as num?)?.toInt() ?? 0,
      activeUsers: (ov['activeUsers'] as num?)?.toInt() ?? 0,
      bannedUsers: (ov['bannedUsers'] as num?)?.toInt() ?? 0,
      totalOrders: (ov['totalOrders'] as num?)?.toInt() ?? 0,
      activePackages: (ov['activePackages'] as num?)?.toInt() ?? 0,
      completedOrders: (ov['completedOrders'] as num?)?.toInt() ?? 0,
      totalPlatformVolume:
          (ov['totalPlatformVolume'] as num?)?.toDouble() ?? 0.0,
      totalUserBalanceFloat:
          (ov['totalUserBalanceFloat'] as num?)?.toDouble() ?? 0.0,
      pendingPayoutsCount: (ov['pendingPayoutsCount'] as num?)?.toInt() ?? 0,
      totalPendingPayoutsAmount:
          (ov['totalPendingPayoutsAmount'] as num?)?.toDouble() ?? 0.0,
      totalPayoutsSettled:
          (ov['totalPayoutsSettled'] as num?)?.toDouble() ?? 0.0,
      marketStatus: json['marketStatus'] as String? ?? 'ONLINE',
      serverTime: json['serverTime'] as String? ?? '',
    );
  }

  static const empty = AdminStats();
}

/// Pending PhonePe Payout Item
class AdminPayoutItem {
  final int id;
  final int userId;
  final String userEmail;
  final String userMobile;
  final String userInviteCode;
  final double amount;
  final double profitAccumulated;
  final String paymentMethod;
  final String destinationUpi;
  final String status;
  final String requestedAt;

  const AdminPayoutItem({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userMobile,
    required this.userInviteCode,
    required this.amount,
    required this.profitAccumulated,
    required this.paymentMethod,
    required this.destinationUpi,
    required this.status,
    required this.requestedAt,
  });

  factory AdminPayoutItem.fromJson(Map<String, dynamic> json) {
    return AdminPayoutItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userEmail: json['userEmail'] as String? ?? 'N/A',
      userMobile: json['userMobile'] as String? ?? 'N/A',
      userInviteCode: json['userInviteCode'] as String? ?? 'N/A',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      profitAccumulated: (json['profitAccumulated'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] as String? ?? 'phonepe',
      destinationUpi: json['destinationUpi'] as String? ?? 'UPI Hidden',
      status: json['status'] as String? ?? 'pending',
      requestedAt: json['requestedAt'] as String? ?? '',
    );
  }
}

/// Admin User Directory Item
class AdminUserItem {
  final int id;
  final String email;
  final String mobile;
  final String inviteCode;
  final String referredBy;
  final double balance;
  final String level;
  final String status;
  final String createdAt;

  const AdminUserItem({
    required this.id,
    required this.email,
    required this.mobile,
    required this.inviteCode,
    required this.referredBy,
    required this.balance,
    required this.level,
    required this.status,
    required this.createdAt,
  });

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    return AdminUserItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: json['email'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      inviteCode: json['inviteCode'] as String? ?? '',
      referredBy: json['referred_by'] as String? ?? 'DIRECT',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      level: json['level'] as String? ?? 'L1',
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

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

  /// 3. Settle a Payout with Bank UTR Reference
  Future<bool> settlePayout(int payoutId, String utrReference) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.adminSettlePayout(payoutId),
        data: {'utrReference': utrReference},
      );
      if (res.success) {
        // Remove from pending list and refresh stats
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

  /// 4. Fetch All RP Packages
  Future<void> fetchPackages({String level = 'ALL'}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final endpoint = level == 'ALL'
          ? ApiEndpoints.adminPackages
          : '${ApiEndpoints.adminPackages}?level=$level';
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
    required String status,
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
