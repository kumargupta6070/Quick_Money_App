import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/wallet_model.dart';
import '../mock_data/app_mock_data.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class WalletNotifier extends Notifier<WalletModel> {
  ApiClient get _apiClient => ref.read(apiClientProvider);

  @override
  WalletModel build() {
    return AppMockData.wallet;
  }

  /// Fetch live bound wallet from Backend API (GET /wallets)
  Future<void> fetchWallet() async {
    try {
      if (ApiEndpoints.useMockData) return;
      final res = await _apiClient.get(ApiEndpoints.wallet);
      if (res.success && res.data != null) {
        final walletMap = res.data as Map<String, dynamic>;
        state = WalletModel.fromJson(walletMap);
      }
    } catch (_) {
      // Non-blocking fallback
    }
  }

  /// Bind PhonePe UPI ID to live backend (POST /wallets/bind)
  Future<bool> bindWallet({
    required String upiId,
    required String paymentApp,
    String? accountHolderName,
  }) async {
    try {
      if (ApiEndpoints.useMockData) {
        state = state.copyWith(
          upiId: upiId,
          paymentApp: paymentApp,
          accountHolderName: accountHolderName,
          status: WalletStatus.active,
          statusDetail: 'Verified',
          boundAt: DateTime.now(),
        );
        return true;
      }

      final res = await _apiClient.post(
        ApiEndpoints.bindWallet,
        data: {
          'upi_id': upiId.trim(),
          'payment_app': paymentApp,
          'account_holder_name':
              accountHolderName?.trim() ?? 'Primary PhonePe Wallet',
        },
      );

      if (res.success && res.data != null) {
        final walletMap = res.data as Map<String, dynamic>;
        state = WalletModel.fromJson(walletMap);
        return true;
      }
      return res.success;
    } catch (_) {
      return false;
    }
  }

  void updateWallet({required String upiId, required String paymentApp}) {
    state = state.copyWith(
      upiId: upiId,
      paymentApp: paymentApp,
      status: WalletStatus.active,
      statusDetail: 'Verified',
      boundAt: DateTime.now(),
    );
  }
}

final walletProvider = NotifierProvider<WalletNotifier, WalletModel>(() {
  return WalletNotifier();
});
