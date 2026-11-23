import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyLoginTimestamp = 'quick_money_login_timestamp';
  static const String _keyUserData = 'quick_money_cached_user';

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: AppConstants.keyAuthToken, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(
        key: AppConstants.keyRefreshToken,
        value: refreshToken,
      );
    }
    // Automatically record login timestamp for 7-day persistent session
    await saveLoginTimestamp(DateTime.now().millisecondsSinceEpoch);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: AppConstants.keyAuthToken);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: AppConstants.keyRefreshToken);
  }

  Future<void> saveLoginTimestamp(int timestamp) async {
    await _storage.write(key: _keyLoginTimestamp, value: timestamp.toString());
  }

  Future<int?> getLoginTimestamp() async {
    final raw = await _storage.read(key: _keyLoginTimestamp);
    return raw != null ? int.tryParse(raw) : null;
  }

  Future<void> saveUserData(Map<String, dynamic> data) async {
    await _storage.write(key: _keyUserData, value: jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final raw = await _storage.read(key: _keyUserData);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
