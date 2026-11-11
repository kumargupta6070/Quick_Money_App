import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/user_model.dart';
import '../mock_data/app_mock_data.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import 'auth_provider.dart';

class UserNotifier extends Notifier<UserModel> {
  ApiClient get _apiClient => ref.read(apiClientProvider);

  @override
  UserModel build() {
    // Sync with authState whenever user logs in or profile changes
    final authState = ref.watch(authProvider);
    if (authState.isAuthenticated && authState.mobile != null) {
      return UserModel(
        id: 1,
        mobile: authState.mobile ?? '9835913180',
        inviteCode: authState.inviteCode ?? 'x03180',
        balance: authState.balance,
        level: authState.level,
        isVerified: true,
      );
    }
    return AppMockData.user;
  }

  /// Fetch live user profile from Backend API (GET /users/profile)
  Future<void> fetchProfile() async {
    try {
      if (ApiEndpoints.useMockData) return;
      final res = await _apiClient.get(ApiEndpoints.profile);
      if (res.success && res.data != null) {
        final userMap = res.data as Map<String, dynamic>;
        state = UserModel.fromJson(userMap);
      }
    } catch (_) {
      // Non-blocking fallback
    }
  }

  void updateBalance(double newBalance) {
    state = state.copyWith(balance: newBalance);
  }

  void addEarnings(double profit) {
    state = state.copyWith(balance: state.balance + profit);
  }
}

final userProvider = NotifierProvider<UserNotifier, UserModel>(() {
  return UserNotifier();
});
