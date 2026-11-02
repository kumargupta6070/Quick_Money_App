class ReferralModel {
  final int id;
  final int referrerId;
  final int referredId;
  final int level;
  final double totalRebateEarned;

  const ReferralModel({
    required this.id,
    required this.referrerId,
    required this.referredId,
    required this.level,
    this.totalRebateEarned = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrer_id': referrerId,
      'referred_id': referredId,
      'level': level,
      'total_rebate_earned': totalRebateEarned,
    };
  }

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id'] as int? ?? 1,
      referrerId: json['referrer_id'] as int? ?? 1,
      referredId: json['referred_id'] as int? ?? 1,
      level: json['level'] as int? ?? 1,
      totalRebateEarned: (json['total_rebate_earned'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

