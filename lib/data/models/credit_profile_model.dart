class CreditProfileModel {
  const CreditProfileModel({
    required this.id,
    required this.userId,
    this.creditScore,
    this.riskBand,
    this.approvedBorrowingLimit,
    this.modelVersion,
    this.lastAssessedAt,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final int? creditScore;
  final String? riskBand;
  final double? approvedBorrowingLimit;
  final String? modelVersion;
  final DateTime? lastAssessedAt;
  final DateTime createdAt;

  /// Credit score expressed as a 0–1 fraction for progress indicators.
  double get scoreProgress => creditScore == null ? 0 : creditScore! / 100;

  factory CreditProfileModel.fromJson(Map<String, dynamic> json) {
    return CreditProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      creditScore: json['credit_score'] as int?,
      riskBand: json['risk_band'] as String?,
      approvedBorrowingLimit:
          (json['approved_borrowing_limit'] as num?)?.toDouble(),
      modelVersion: json['model_version'] as String?,
      lastAssessedAt: json['last_assessed_at'] != null
          ? DateTime.parse(json['last_assessed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
