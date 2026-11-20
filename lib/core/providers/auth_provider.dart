import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/api_exception.dart';
import '../services/secure_storage_service.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? token;
  final String? error;
  final String? role; // 'user' or 'admin'
  final String? mobile;
  final String? email;
  final double balance;
  final String level;
  final String? inviteCode;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.token,
    this.error,
    this.role = 'user',
    this.mobile,
    this.email,
    this.balance = 0.0,
    this.level = 'L1',
    this.inviteCode,
  });

  bool get isAdmin => role == 'admin';

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? token,
    String? error,
    String? role,
    String? mobile,
    String? email,
    double? balance,
    String? level,
    String? inviteCode,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      error: error,
      role: role ?? this.role,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      balance: balance ?? this.balance,
      level: level ?? this.level,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  ApiClient get _apiClient => ref.read(apiClientProvider);
  SecureStorageService get _storage => ref.read(secureStorageServiceProvider);

  String _extractError(dynamic e) {
    if (e is ApiException) {
      return e.message;
    }
    final raw = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    return raw.isNotEmpty
        ? raw
        : 'An unexpected error occurred. Please try again.';
  }

  /// Send verification code via Brevo Email SMTP
  Future<bool> sendRegisterOtp({
    required String email,
    required String mobile,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (ApiEndpoints.useMockData) {
        await Future.delayed(const Duration(milliseconds: 600));
        state = state.copyWith(isLoading: false);
        return true;
      }

      final res = await _apiClient.post(
        ApiEndpoints.sendOtp,
        data: {
          'email': email.trim().toLowerCase(),
          'mobile': mobile.trim(),
          'type': 'register',
        },
      );

      state = state.copyWith(isLoading: false);
      if (!res.success) {
        state = state.copyWith(error: res.message);
      }
      return res.success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
      return false;
    }
  }

  /// Send Password Reset OTP to registered email
  Future<bool> sendPasswordResetOtp(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (ApiEndpoints.useMockData) {
        await Future.delayed(const Duration(milliseconds: 600));
        state = state.copyWith(isLoading: false);
        return true;
      }

      final res = await _apiClient.post(
        ApiEndpoints.sendOtp,
        data: {'email': email.trim().toLowerCase(), 'type': 'forgot_password'},
      );

      state = state.copyWith(isLoading: false);
      if (!res.success) {
        state = state.copyWith(error: res.message);
      }
      return res.success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
      return false;
    }
  }

  /// Verify OTP code independently (e.g., for forgot password or general email verification)
  Future<bool> verifyOtp(String otp, {String? email, String? type}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (ApiEndpoints.useMockData) {
        await Future.delayed(const Duration(milliseconds: 600));
        state = state.copyWith(isLoading: false);
        return true;
      }

      final targetEmail = (email ?? state.email ?? '').trim().toLowerCase();
      final payload = <String, dynamic>{
        'email': targetEmail,
        'otp': otp.trim(),
      };
      if (type != null) {
        payload['type'] = type;
      }

      final res = await _apiClient.post(ApiEndpoints.verifyOtp, data: payload);

      state = state.copyWith(isLoading: false);
      if (!res.success) {
        state = state.copyWith(error: res.message);
      }
      return res.success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
      return false;
    }
  }

  /// Register user with verified Email OTP
  Future<bool> register({
    required String mobile,
    required String email,
    required String password,
    required String inviteCode,
    required String otp,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (ApiEndpoints.useMockData) {
        await Future.delayed(const Duration(milliseconds: 800));
        await _storage.saveTokens(accessToken: 'mock_jwt_token_2026');
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          mobile: mobile,
          email: email,
          inviteCode: 'x0${mobile.substring(mobile.length - 4)}',
          token: 'mock_jwt_token_2026',
        );
        return true;
      }

      final res = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'mobile': mobile.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
          'inviteCode': inviteCode.trim(),
          'otp': otp.trim(),
        },
      );

      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        final token = data['token'] as String? ?? '';
        final user = data['user'] as Map<String, dynamic>? ?? {};

        await _storage.saveTokens(accessToken: token);

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          token: token,
          mobile: user['mobile']?.toString() ?? mobile,
          email: user['email']?.toString() ?? email,
          inviteCode: user['invite_code']?.toString(),
          balance:
          double.tryParse(user['balance']?.toString() ?? '0') ?? 0.0,
          level: user['level']?.toString() ?? 'L1',
          role: user['role']?.toString() ?? 'user',
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: res.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
      return false;
    }
  }

  /// Authenticate with Mobile/Email & Password
  Future<bool> login({
    required String mobile,
    String? email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (ApiEndpoints.useMockData) {
        await Future.delayed(const Duration(milliseconds: 800));
        await _storage.saveTokens(accessToken: 'mock_jwt_token_2026');
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          token: 'mock_jwt_token_2026',
          mobile: mobile,
          email: email,
        );
        return true;
      }

      final payload = <String, dynamic>{
        'mobile': mobile.trim(),
        'password': password,
      };
      if (email != null && email.trim().isNotEmpty) {
        payload['email'] = email.trim().toLowerCase();
      }

      final res = await _apiClient.post(ApiEndpoints.login, data: payload);

      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        final token = data['token'] as String? ?? '';
        final user = data['user'] as Map<String, dynamic>? ?? {};

        await _storage.saveTokens(accessToken: token);

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          token: token,
          mobile: user['mobile']?.toString() ?? mobile,
          email: user['email']?.toString() ?? email,
          inviteCode: user['invite_code']?.toString(),
          balance:
          double.tryParse(user['balance']?.toString() ?? '0') ?? 0.0,
          level: user['level']?.toString() ?? 'L1',
          role: user['role']?.toString() ?? 'user',
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: res.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
      return false;
    }
  }

  /// Change Password for authenticated user
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (ApiEndpoints.useMockData) {
        await Future.delayed(const Duration(milliseconds: 600));
        state = state.copyWith(isLoading: false);
        return true;
      }

      final res = await _apiClient.post(
        ApiEndpoints.changePassword,
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );

      state = state.copyWith(isLoading: false);
      if (!res.success) {
        state = state.copyWith(error: res.message);
      }
      return res.success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
      return false;
    }
  }

  /// Fetch live user profile using active JWT
  Future<void> fetchProfile() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.me);
      if (res.success && res.data != null) {
        final user = res.data as Map<String, dynamic>;
        state = state.copyWith(
          mobile: user['mobile']?.toString(),
          email: user['email']?.toString(),
          inviteCode: user['invite_code']?.toString(),
          balance:
          double.tryParse(user['balance']?.toString() ?? '0') ?? 0.0,
          level: user['level']?.toString() ?? 'L1',
          role: user['role']?.toString() ?? 'user',
        );
      }
    } catch (e) {
      // Non-blocking background sync failure
    }
  }

  /// Reset Password with Email OTP
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email.trim().toLowerCase(),
          'otp': otp.trim(),
          'newPassword': newPassword,
        },
      );
      state = state.copyWith(isLoading: false);
      if (!res.success) {
        state = state.copyWith(error: res.message);
      }
      return res.success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
      return false;
    }
  }

  /// Sign out
  Future<void> logout() async {
    await _storage.clearAll();
    state = const AuthState(isAuthenticated: false, token: null);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
