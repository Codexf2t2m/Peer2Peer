
// UC: Run Credit Assessment
// Result returned from the credit assessment RPC.

class CreditAssessmentResultModel {
  const CreditAssessmentResultModel({
    required this.creditScore,
    required this.riskBand,
    required this.borrowingLimit,
    required this.modelVersion,
    required this.assessedAt,
  });

  /// Raw score 0–1000.
  final int creditScore;

  /// 'Excellent' | 'Good' | 'Fair' | 'Poor'
  final String riskBand;

  /// Approved borrowing limit in BWP.
  final double borrowingLimit;

  final String modelVersion;
  final DateTime assessedAt;

  double get scorePercent => (creditScore / 1000.0).clamp(0.0, 1.0);

  factory CreditAssessmentResultModel.fromJson(
      Map<String, dynamic> json) {
    return CreditAssessmentResultModel(
      creditScore:
          (json['credit_score'] as num?)?.toInt() ?? 0,
      riskBand: json['risk_band'] as String? ?? 'Fair',
      borrowingLimit:
          (json['borrowing_limit'] as num?)?.toDouble() ??
              0,
      modelVersion:
          json['model_version'] as String? ?? '1.0',
      assessedAt: json['assessed_at'] != null
          ? DateTime.parse(json['assessed_at'] as String)
          : DateTime.now(),
    );
  }
}