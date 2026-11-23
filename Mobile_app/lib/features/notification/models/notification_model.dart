/// Notification Type Categorization
enum NotificationType {
  order, // Buy RP completed, profit auto-credited
  rebate, // Team 3-level commission received
  reward, // Newbie bonus / login reward
  security, // Login from new device, password change, payment bound
  system, // System maintenance, market liquidity announcement
}

/// Notification Model for Quick Money FinTech Platform
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String detailedMessage;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final double? amount;
  final String? actionRoute;
  final String? actionLabel;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.detailedMessage,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.amount,
    this.actionRoute,
    this.actionLabel,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? detailedMessage,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    double? amount,
    String? actionRoute,
    String? actionLabel,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      detailedMessage: detailedMessage ?? this.detailedMessage,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      amount: amount ?? this.amount,
      actionRoute: actionRoute ?? this.actionRoute,
      actionLabel: actionLabel ?? this.actionLabel,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    NotificationType nType = NotificationType.system;
    final typeStr = json['type']?.toString().toLowerCase();
    if (typeStr == 'order' || typeStr == 'transaction') {
      nType = NotificationType.order;
    } else if (typeStr == 'rebate') {
      nType = NotificationType.rebate;
    } else if (typeStr == 'reward') {
      nType = NotificationType.reward;
    } else if (typeStr == 'security') {
      nType = NotificationType.security;
    }

    return NotificationModel(
      id: json['id']?.toString() ?? 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Quick Money Notification',
      message: json['message']?.toString() ?? '',
      detailedMessage: json['detailed_message']?.toString() ?? json['message']?.toString() ?? '',
      type: nType,
      timestamp: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['is_read'] == true || json['is_read'] == 1,
      amount: double.tryParse(json['amount']?.toString() ?? ''),
      actionRoute: json['action_route']?.toString(),
      actionLabel: json['action_label']?.toString(),
    );
  }
}

