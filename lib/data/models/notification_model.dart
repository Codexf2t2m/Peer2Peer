class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String type;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  String get displayTitle {
    switch (type) {
      case 'loan_funded':
        return 'Loan funded';
      case 'repayment_received':
        return 'Repayment received';
      case 'loan_request_active':
        return 'Request is live';
      case 'loan_request_expired':
        return 'Request expired';
      case 'credit_assessed':
        return 'Credit assessed';
      case 'account_activated':
        return 'Account activated';
      case 'badge_earned':
        return 'Badge earned';
      default:
        return type.replaceAll('_', ' ');
    }
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
