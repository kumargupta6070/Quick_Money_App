import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/user_model.dart';
import '../mock_data/app_mock_data.dart';

class UserNotifier extends Notifier<UserModel> {
  @override
  UserModel build() {
    return AppMockData.user;
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

