import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/transaction_model.dart';
import '../mock_data/app_mock_data.dart';

class TransactionNotifier extends Notifier<List<TransactionModel>> {
  @override
  List<TransactionModel> build() {
    return List.from(AppMockData.transactions);
  }

  void addTransaction(TransactionModel tx) {
    state = [tx, ...state];
  }
}

final transactionProvider = NotifierProvider<TransactionNotifier, List<TransactionModel>>(() {
  return TransactionNotifier();
});

