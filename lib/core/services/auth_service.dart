import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import 'secure_storage_service.dart';

class AuthService {
  final ApiClient _client;
  final SecureStorageService _storage;

  AuthService(this._client, this._storage);

  Future<bool> login(String mobile, String password) async {
    if (ApiEndpoints.useMockData) {
      await Future.delayed(const Duration(milliseconds: 600));
      await _storage.saveTokens(accessToken: 'mock_jwt_token_2026');
      return true;
    }

    final res = await _client.post(
      ApiEndpoints.login,
      data: {'mobile': mobile, 'password': password},
    );
    if (res.success && res.data != null) {
      final token = res.data['token'] as String;
      await _storage.saveTokens(accessToken: token);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }
}

