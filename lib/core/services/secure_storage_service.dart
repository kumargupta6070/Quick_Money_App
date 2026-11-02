import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: AppConstants.keyAuthToken);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: AppConstants.keyRefreshToken);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
