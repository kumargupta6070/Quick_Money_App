import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/api_exception.dart';
import '../services/secure_storage_service.dart';
import 'auth_state.dart';

export 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  ApiClient get _apiClient => ref.read(apiClientProvider);
  SecureStorageService get _storage => ref.read(secureStorageServiceProvider);

  String _extractError(dynamic e) {
    if (e is ApiException) return e.message;
    final raw = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    return raw.isNotEmpty ? raw : 'An unexpected error occurred. Please try again.';
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
        data: {'email': email.trim().toLowerCase(), 'mobile': mobile.trim(), 'type': 'register'},
      );
      state = state.copyWith(isLoading: false);
      if (!res.success) state = state.copyWith(error: res.message);
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
      if (!res.success) state = state.copyWith(error: res.message);
      return res.success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
      return false;
    }
  }

  /// Verify OTP code independently
  Future<bool> verifyOtp(String otp, {String? email, String? type}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (ApiEndpoints.useMockData) {
        await Future.delayed(const Duration(milliseconds: 600));
        state = state.copyWith(isLoading: false);
        return true;
      }
      final payload = <String, dynamic>{
        'email': (email ?? state.email ?? '').trim().toLowerCase(),
        'otp': otp.trim(),
      };
      if (type != null) payload['type'] = type;
      final res = await _apiClient.post(ApiEndpoints.verifyOtp, data: payload);
      state = state.copyWith(isLoading: false);
      if (!res.success) state = state.copyWith(error: res.message);
      return res.success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
      return false;
    }
  }
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
        await _storage.saveUserData(user);

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

  /// Authenticate with Mobile/Email & Password (Step 1: Credentials -> Dispatches Email OTP)
  Future<LoginResponse> login({
    required String mobile,
    String? email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (ApiEndpoints.useMockData) {
        await Future.delayed(const Duration(milliseconds: 600));
        state = state.copyWith(isLoading: false);
        return LoginResponse(
          success: true,
          requiresOtp: true,
          email: email ?? 'investor@quickmoney.in',
          mobile: mobile,
          message: 'Security code dispatched to your registered email address.',
        );
      }

      final payload = <String, dynamic>{
        'mobile': mobile.trim(),
        'password': password,
      };
      if (email != null && email.trim().isNotEmpty) {
        payload['email'] = email.trim().toLowerCase();
      }

      final res = await _apiClient.post(ApiEndpoints.login, data: payload);

      state = state.copyWith(isLoading: false);
      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        final requiresOtp = data['requiresOtp'] == true;
        final targetEmail = data['email']?.toString() ?? email;
        final targetMobile = data['mobile']?.toString() ?? mobile;

        if (data['token'] != null) {
          final token = data['token'] as String;
          final user = data['user'] as Map<String, dynamic>? ?? {};
          await _storage.saveTokens(accessToken: token);
        await _storage.saveUserData(user);
          state = state.copyWith(
            isAuthenticated: true,
            token: token,
            mobile: user['mobile']?.toString() ?? mobile,
            email: user['email']?.toString() ?? email,
            inviteCode: user['invite_code']?.toString(),
            balance: double.tryParse(user['balance']?.toString() ?? '0') ?? 0.0,
            level: user['level']?.toString() ?? 'L1',
            role: user['role']?.toString() ?? 'user',
          );
        }

        return LoginResponse(
          success: true,
          requiresOtp: requiresOtp,
          email: targetEmail,
          mobile: targetMobile,
          message: res.message,
        );
      } else {
        state = state.copyWith(error: res.message);
        return LoginResponse(
          success: false,
          error: res.message,
        );
      }
    } catch (e) {
      final err = _extractError(e);
      state = state.copyWith(isLoading: false, error: err);
      return LoginResponse(success: false, error: err);
    }
  }

  /// Step 2: Verify Login OTP and issue authenticated session
  Future<bool> verifyLoginOtp({
    required String email,
    required String otp,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (ApiEndpoints.useMockData) {
        await Future.delayed(const Duration(milliseconds: 600));
        await _storage.saveTokens(accessToken: 'mock_jwt_token_2026');
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          token: 'mock_jwt_token_2026',
          email: email,
          role: email.contains('admin') ? 'admin' : 'user',
        );
        return true;
      }

      final res = await _apiClient.post(
        ApiEndpoints.loginVerifyOtp,
        data: {
          'email': email.trim().toLowerCase(),
          'otp': otp.trim(),
        },
      );

      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        final token = data['token'] as String? ?? '';
        final user = data['user'] as Map<String, dynamic>? ?? {};

        await _storage.saveTokens(accessToken: token);
        await _storage.saveUserData(user);

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          token: token,
          mobile: user['mobile']?.toString() ?? state.mobile,
          email: user['email']?.toString() ?? email,
          inviteCode: user['invite_code']?.toString(),
          balance: double.tryParse(user['balance']?.toString() ?? '0') ?? 0.0,
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

  /// Resend login OTP to email
  Future<bool> sendLoginOtp(String email) async {
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
          'type': 'login',
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
      if (!res.success) state = state.copyWith(error: res.message);
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
        final u = res.data as Map<String, dynamic>;
        await _storage.saveUserData(u);
        state = state.copyWith(
          mobile: u['mobile']?.toString(),
          email: u['email']?.toString(),
          inviteCode: u['invite_code']?.toString(),
          balance: double.tryParse(u['balance']?.toString() ?? '0') ?? 0.0,
          level: u['level']?.toString() ?? 'L1',
          role: u['role']?.toString() ?? 'user',
        );
      }
    } catch (_) {}
  }

  /// Reset Password with Email OTP
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _apiClient.post(ApiEndpoints.resetPassword, data: {
        'email': email.trim().toLowerCase(),
        'otp': otp.trim(),
        'newPassword': newPassword,
      });
      state = state.copyWith(isLoading: false);
      if (!res.success) state = state.copyWith(error: res.message);
      return res.success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
      return false;
    }
  }

  /// Check and restore 7-day persistent login session
  Future<bool> checkAndRestoreSession() async {
    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      // 7-day session validity check (7 days in milliseconds)
      const sevenDaysMs = 7 * 24 * 60 * 60 * 1000;
      final loginTs = await _storage.getLoginTimestamp();
      if (loginTs != null) {
        final elapsed = DateTime.now().millisecondsSinceEpoch - loginTs;
        if (elapsed > sevenDaysMs) {
          // 7 days completed! Expire session and require full re-authentication
          await logout();
          return false;
        }
      } else {
        await _storage.saveLoginTimestamp(DateTime.now().millisecondsSinceEpoch);
      }

      if (ApiEndpoints.useMockData) {
        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          role: 'user',
        );
        return true;
      }

      final res = await _apiClient.get(ApiEndpoints.me);
      if (res.success && res.data != null) {
        final u = res.data as Map<String, dynamic>;
        await _storage.saveUserData(u);
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          token: token,
          mobile: u['mobile']?.toString() ?? state.mobile,
          email: u['email']?.toString() ?? state.email,
          inviteCode: u['invite_code']?.toString(),
          balance: double.tryParse(u['balance']?.toString() ?? '0') ?? 0.0,
          level: u['level']?.toString() ?? 'L1',
          role: u['role']?.toString() ?? 'user',
        );
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (_) {
      // Offline fallback: if valid token and within 7 days, restore cached user
      final token = await _storage.getAccessToken();
      final loginTs = await _storage.getLoginTimestamp();
      if (token != null && token.isNotEmpty && loginTs != null) {
        final elapsed = DateTime.now().millisecondsSinceEpoch - loginTs;
        const sevenDaysMs = 7 * 24 * 60 * 60 * 1000;
        if (elapsed <= sevenDaysMs) {
          final cached = await _storage.getUserData();
          if (cached != null) {
            state = state.copyWith(
              isAuthenticated: true,
              token: token,
              mobile: cached['mobile']?.toString(),
              email: cached['email']?.toString(),
              inviteCode: cached['invite_code']?.toString(),
              balance: double.tryParse(cached['balance']?.toString() ?? '0') ?? 0.0,
              level: cached['level']?.toString() ?? 'L1',
              role: cached['role']?.toString() ?? 'user',
            );
            return true;
          }
        }
      }
      return false;
    }
  }

  /// Sign out
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (_) {}
    await _storage.clearAll();
    state = const AuthState(isAuthenticated: false, token: null);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
