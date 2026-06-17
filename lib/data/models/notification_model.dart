// lib/data/models/notification_model.dart
//
// Maps to the NOTIFICATIONS table:
//   id, user_id, type, message, is_read, created_at

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

  String get title {
    return switch (type) {
      'repayment_received' => 'Repayment Received',
      'loan_funded'        => 'Loan Funded',
      'limit_change'       => 'Limit Updated',
      'kyc_approved'       => 'KYC Approved',
      'overdraft_warning'  => 'Overdraft Warning',
      _ => type
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.isEmpty
                ? ''
                : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' '),
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String? ?? 'notification',
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}