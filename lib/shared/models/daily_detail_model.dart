class DailyDetailModel {
  final String date;
  final double totalIncome;
  final int purchaseNumber;
  final double purchaseAmount;
  final double brokerage;
  final double teamRebates;
  final double subordinateRebates;
  final double usdtRecharge;
  final double trxRecharge;
  final int sellNumber;
  final double sellAmount;
  final double activityReward;
  final double otherReward;

  const DailyDetailModel({
    required this.date,
    required this.totalIncome,
    required this.purchaseNumber,
    required this.purchaseAmount,
    required this.brokerage,
    this.teamRebates = 0.0,
    this.subordinateRebates = 0.0,
    this.usdtRecharge = 0.0,
    this.trxRecharge = 0.0,
    required this.sellNumber,
    required this.sellAmount,
    this.activityReward = 0.0,
    this.otherReward = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'total_income': totalIncome,
      'purchase_number': purchaseNumber,
      'purchase_amount': purchaseAmount,
      'brokerage': brokerage,
      'team_rebates': teamRebates,
      'subordinate_rebates': subordinateRebates,
      'usdt_recharge': usdtRecharge,
      'trx_recharge': trxRecharge,
      'sell_number': sellNumber,
      'sell_amount': sellAmount,
      'activity_reward': activityReward,
      'other_reward': otherReward,
    };
  }

  factory DailyDetailModel.fromJson(Map<String, dynamic> json) {
    return DailyDetailModel(
      date: json['date'] as String? ?? '',
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
      purchaseNumber: json['purchase_number'] as int? ?? 0,
      purchaseAmount: (json['purchase_amount'] as num?)?.toDouble() ?? 0.0,
      brokerage: (json['brokerage'] as num?)?.toDouble() ?? 0.0,
      teamRebates: (json['team_rebates'] as num?)?.toDouble() ?? 0.0,
      subordinateRebates: (json['subordinate_rebates'] as num?)?.toDouble() ?? 0.0,
      usdtRecharge: (json['usdt_recharge'] as num?)?.toDouble() ?? 0.0,
      trxRecharge: (json['trx_recharge'] as num?)?.toDouble() ?? 0.0,
      sellNumber: json['sell_number'] as int? ?? 0,
      sellAmount: (json['sell_amount'] as num?)?.toDouble() ?? 0.0,
      activityReward: (json['activity_reward'] as num?)?.toDouble() ?? 0.0,
      otherReward: (json['other_reward'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

