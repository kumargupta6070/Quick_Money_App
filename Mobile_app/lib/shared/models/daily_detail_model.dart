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
      date: (json['profit_date'] ?? json['date'])?.toString() ?? '',
      totalIncome:
          double.tryParse(json['total_income']?.toString() ?? '0') ?? 0.0,
      purchaseNumber:
          int.tryParse(json['purchase_number']?.toString() ?? '0') ?? 0,
      purchaseAmount:
          double.tryParse(json['purchase_amount']?.toString() ?? '0') ?? 0.0,
      brokerage: double.tryParse(json['brokerage']?.toString() ?? '0') ?? 0.0,
      teamRebates:
          double.tryParse(json['team_rebates']?.toString() ?? '0') ?? 0.0,
      subordinateRebates:
          double.tryParse(json['subordinate_rebates']?.toString() ?? '0') ??
          0.0,
      usdtRecharge:
          double.tryParse(json['usdt_recharge']?.toString() ?? '0') ?? 0.0,
      trxRecharge:
          double.tryParse(json['trx_recharge']?.toString() ?? '0') ?? 0.0,
      sellNumber: int.tryParse(json['sell_number']?.toString() ?? '0') ?? 0,
      sellAmount:
          double.tryParse(json['sell_amount']?.toString() ?? '0') ?? 0.0,
      activityReward:
          double.tryParse(json['activity_reward']?.toString() ?? '0') ?? 0.0,
      otherReward:
          double.tryParse(json['other_reward']?.toString() ?? '0') ?? 0.0,
    );
  }
}
