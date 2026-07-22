
// Maps to the CREDIT_PROFILES table:
//   id, user_id, credit_score, risk_band,
//   approved_borrowing_limit, model_version, last_assessed_at
//
// UC: View Credit Score + View Borrowing Limit

/// Immutable snapshot of the user's credit profile.
class CreditProfileModel {
  const CreditProfileModel({
    required this.id,
    required this.userId,
    required this.creditScore,
    required this.riskBand,
    required this.approvedBorrowingLimit,
    required this.modelVersion,
    required this.lastAssessedAt,
  });

  final String id;
  final String userId;

  /// Raw credit score (0–1000).
  final int creditScore;

  /// 'Excellent' | 'Good' | 'Fair' | 'Poor'
  final String riskBand;

  /// Maximum approved borrowing amount (BWP).
  final double approvedBorrowingLimit;

  final String modelVersion;
  final DateTime lastAssessedAt;

  // Computed display properties 

  /// Score as a 0.0–1.0 fraction (out of 1000).
  double get scorePercent => (creditScore / 1000.0).clamp(0.0, 1.0);

  /// Score as a rounded percentage string.
  String get scorePercentLabel =>
      '${(scorePercent * 100).round()}%';

  /// Next review date — 90 days after the last assessment.
  DateTime get nextReviewDate =>
      lastAssessedAt.add(const Duration(days: 90));

  String get nextReviewLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final d = nextReviewDate;
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  static final empty = CreditProfileModel(
    id: '',
    userId: '',
    creditScore: 0,
    riskBand: 'Fair',
    approvedBorrowingLimit: 0,
    modelVersion: '',
    lastAssessedAt: _epoch,
  );

  static final _epoch = DateTime.utc(1970);

  factory CreditProfileModel.fromJson(Map<String, dynamic> json) {
    return CreditProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      creditScore: (json['credit_score'] as num?)?.toInt() ?? 0,
      riskBand: json['risk_band'] as String? ?? 'Fair',
      approvedBorrowingLimit:
          (json['approved_borrowing_limit'] as num?)?.toDouble() ??
              0,
      modelVersion: json['model_version'] as String? ?? '',
      lastAssessedAt: DateTime.parse(
          json['last_assessed_at'] as String? ??
              DateTime.now().toIso8601String()),
    );
  }
}