class ProfitModel {
  final int id;
  final int userId;
  final String date;
  final double totalIncome;
  final double brokerage;
  final double teamRebates;

  const ProfitModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.totalIncome,
    this.brokerage = 0.0,
    this.teamRebates = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'total_income': totalIncome,
      'brokerage': brokerage,
      'team_rebates': teamRebates,
    };
  }

  factory ProfitModel.fromJson(Map<String, dynamic> json) {
    return ProfitModel(
      id: json['id'] as int? ?? 1,
      userId: json['user_id'] as int? ?? 1,
      date: json['date'] as String? ?? '',
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
      brokerage: (json['brokerage'] as num?)?.toDouble() ?? 0.0,
      teamRebates: (json['team_rebates'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

