import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/wallet_model.dart';
import '../mock_data/app_mock_data.dart';

class WalletNotifier extends Notifier<WalletModel> {
  @override
  WalletModel build() {
    return AppMockData.wallet;
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

