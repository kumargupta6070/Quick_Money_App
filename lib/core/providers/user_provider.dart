import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/user_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import 'auth_provider.dart';

class UserNotifier extends Notifier<UserModel> {
  ApiClient get _apiClient => ref.read(apiClientProvider);

  @override
  UserModel build() {
    // Initial fetch in background whenever user model is initialized
    Future.microtask(() => fetchProfile());

    // Sync with authState whenever user logs in or profile changes
    final authState = ref.watch(authProvider);
    if (authState.isAuthenticated) {
      return UserModel(
        id: 1,
        mobile: authState.mobile ?? '',
        email: authState.email ?? '',
        inviteCode: authState.inviteCode ?? '',
        balance: authState.balance,
        level: authState.level,
        isVerified: true,
      );
    }
    return const UserModel(
      id: 0,
      mobile: '',
      email: '',
      inviteCode: '',
      balance: 0.0,
      level: 'L1',
      isVerified: false,
    );
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
