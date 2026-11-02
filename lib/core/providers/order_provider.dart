import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/order_model.dart';
import '../mock_data/app_mock_data.dart';

class OrderState {
  final String selectedLevel;
  final List<OrderModel> orders;
  final bool isLoading;
  final String sortOrder; // 'low_to_high' or 'high_to_low'

  const OrderState({
    this.selectedLevel = 'L1',
    this.orders = const [],
    this.isLoading = false,
    this.sortOrder = 'low_to_high',
  });

  OrderState copyWith({
    String? selectedLevel,
    List<OrderModel>? orders,
    bool? isLoading,
    String? sortOrder,
  }) {
    return OrderState(
      selectedLevel: selectedLevel ?? this.selectedLevel,
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class OrderNotifier extends Notifier<OrderState> {
  @override
  OrderState build() {
    return OrderState(
      selectedLevel: 'L1',
      orders: List.from(AppMockData.ordersL1),
    );
  }

  void changeLevel(String level) {
    state = state.copyWith(isLoading: true, selectedLevel: level);
    final rawOrders = AppMockData.getOrdersForLevel(level);
    _applySort(rawOrders, state.sortOrder);
  }

  void toggleSortOrder() {
    final newSort = state.sortOrder == 'low_to_high' ? 'high_to_low' : 'low_to_high';
    _applySort(List.from(state.orders), newSort);
  }

  void _applySort(List<OrderModel> list, String sortOrder) {
    if (sortOrder == 'low_to_high') {
      list.sort((a, b) => a.orderAmount.compareTo(b.orderAmount));
    } else {
      list.sort((a, b) => b.orderAmount.compareTo(a.orderAmount));
    }
    state = state.copyWith(orders: list, isLoading: false, sortOrder: sortOrder);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));
    changeLevel(state.selectedLevel);
  }

  Future<bool> receiveOrder(int orderId) async {
    final index = state.orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final updatedList = List<OrderModel>.from(state.orders);
      updatedList.removeAt(index);
      state = state.copyWith(orders: updatedList);
      return true;
    }
    return false;
  }
}

final orderProvider = NotifierProvider<OrderNotifier, OrderState>(() {
  return OrderNotifier();
});

