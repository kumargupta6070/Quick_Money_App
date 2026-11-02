enum OrderStatus { active, receiving, completed, cancelled }

class OrderModel {
  final int id;
  final double orderAmount;
  final int orderQuantity;
  final double reward;
  final double bonus;
  final double finalRp;
  final String level;
  final OrderStatus status;
  final DateTime? createdAt;

  const OrderModel({
    required this.id,
    required this.orderAmount,
    required this.orderQuantity,
    required this.reward,
    this.bonus = 2.0,
    required this.finalRp,
    this.level = 'L1',
    this.status = OrderStatus.active,
    this.createdAt,
  });

  OrderModel copyWith({
    int? id,
    double? orderAmount,
    int? orderQuantity,
    double? reward,
    double? bonus,
    double? finalRp,
    String? level,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderAmount: orderAmount ?? this.orderAmount,
      orderQuantity: orderQuantity ?? this.orderQuantity,
      reward: reward ?? this.reward,
      bonus: bonus ?? this.bonus,
      finalRp: finalRp ?? this.finalRp,
      level: level ?? this.level,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_amount': orderAmount,
      'order_quantity': orderQuantity,
      'reward': reward,
      'bonus': bonus,
      'final_rp': finalRp,
      'level': level,
      'status': status.name,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int? ?? 1,
      orderAmount: (json['order_amount'] as num?)?.toDouble() ?? 0.0,
      orderQuantity: json['order_quantity'] as int? ?? 1,
      reward: (json['reward'] as num?)?.toDouble() ?? 0.0,
      bonus: (json['bonus'] as num?)?.toDouble() ?? 2.0,
      finalRp: (json['final_rp'] as num?)?.toDouble() ?? 0.0,
      level: json['level'] as String? ?? 'L1',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.active,
      ),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}

