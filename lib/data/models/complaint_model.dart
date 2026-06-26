
// Maps to the COMPLAINTS table in the ERD:
//   id, user_id, against_user_id, type, status, created_at
//
// The `description` column is not in the ERD but is standard for
// complaint submissions — included as an optional field.

/// All complaint types available to the submitting user.
enum ComplaintType {
  fraud,
  harassment,
  nonRepayment,
  impersonation,
  platformBug,
  other;

  static ComplaintType fromString(String value) {
    return switch (value) {
      'fraud' => ComplaintType.fraud,
      'harassment' => ComplaintType.harassment,
      'non_repayment' => ComplaintType.nonRepayment,
      'impersonation' => ComplaintType.impersonation,
      'platform_bug' => ComplaintType.platformBug,
      _ => ComplaintType.other,
    };
  }

  String toApiString() {
    return switch (this) {
      ComplaintType.fraud => 'fraud',
      ComplaintType.harassment => 'harassment',
      ComplaintType.nonRepayment => 'non_repayment',
      ComplaintType.impersonation => 'impersonation',
      ComplaintType.platformBug => 'platform_bug',
      ComplaintType.other => 'other',
    };
  }
}

/// Complaint status as managed by admin (UC: Resolve Complaints).
enum ComplaintStatus {
  open,
  inReview,
  resolved,
  dismissed;

  static ComplaintStatus fromString(String value) {
    return switch (value) {
      'in_review' => ComplaintStatus.inReview,
      'resolved' => ComplaintStatus.resolved,
      'dismissed' => ComplaintStatus.dismissed,
      _ => ComplaintStatus.open,
    };
  }
}

/// Immutable record of a submitted complaint.
class ComplaintModel {
  const ComplaintModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.createdAt,
    this.againstUserId,
    this.description,
  });

  final String id;
  final String userId;
  final ComplaintType type;
  final ComplaintStatus status;
  final DateTime createdAt;

  /// The user being complained about — null for platform/bug reports.
  final String? againstUserId;
  final String? description;

  bool get isPending =>
      status == ComplaintStatus.open ||
      status == ComplaintStatus.inReview;

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      againstUserId: json['against_user_id'] as String?,
      type: ComplaintType.fromString(
          json['type'] as String? ?? 'other'),
      status: ComplaintStatus.fromString(
          json['status'] as String? ?? 'open'),
      createdAt: DateTime.parse(json['created_at'] as String),
      description: json['description'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplaintModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}