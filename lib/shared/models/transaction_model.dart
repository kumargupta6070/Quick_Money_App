enum TransactionType { buy, sell, deposit, payout, rebate, bonus }
enum TransactionStatus { pending, processing, completed, failed }

class TransactionModel {
  final int id;
  final TransactionType type;
  final double amount;
  final double profit;
  final String paymentMethod; // phonepe, gpay, paytm
  final String? paymentSource; // source UPI
  final String? paymentDestination; // return UPI
  final TransactionStatus status;
  final String? referenceId;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    this.profit = 0.0,
    required this.paymentMethod,
    this.paymentSource,
    this.paymentDestination,
    this.status = TransactionStatus.completed,
    this.referenceId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'profit': profit,
      'payment_method': paymentMethod,
      'payment_source': paymentSource,
      'payment_destination': paymentDestination,
      'status': status.name,
      'reference_id': referenceId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int? ?? 1,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.buy,
      ),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String? ?? 'phonepe',
      paymentSource: json['payment_source'] as String?,
      paymentDestination: json['payment_destination'] as String?,
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.completed,
      ),
      referenceId: json['reference_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }
}

