enum WalletStatus { active, warning, abnormal, pending }

class WalletModel {
  final int id;
  final String paymentApp; // phonepe, googlepay, paytm
  final String upiId;
  final WalletStatus status;
  final String? statusDetail;
  final String? accountHolderName;
  final DateTime? boundAt;

  const WalletModel({
    required this.id,
    required this.paymentApp,
    required this.upiId,
    this.status = WalletStatus.active,
    this.statusDetail,
    this.accountHolderName,
    this.boundAt,
  });

  WalletModel copyWith({
    int? id,
    String? paymentApp,
    String? upiId,
    WalletStatus? status,
    String? statusDetail,
    String? accountHolderName,
    DateTime? boundAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      paymentApp: paymentApp ?? this.paymentApp,
      upiId: upiId ?? this.upiId,
      status: status ?? this.status,
      statusDetail: statusDetail ?? this.statusDetail,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      boundAt: boundAt ?? this.boundAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_app': paymentApp,
      'upi_id': upiId,
      'status': status.name,
      'status_detail': statusDetail,
      'account_holder_name': accountHolderName,
      'bound_at': boundAt?.toIso8601String(),
    };
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as int? ?? 1,
      paymentApp: json['payment_app'] as String? ?? 'phonepe',
      upiId: json['upi_id'] as String? ?? '',
      status: WalletStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WalletStatus.active,
      ),
      statusDetail: json['status_detail'] as String?,
      accountHolderName: json['account_holder_name'] as String?,
      boundAt: json['bound_at'] != null ? DateTime.tryParse(json['bound_at'].toString()) : null,
    );
  }
}

