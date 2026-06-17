
// Aggregates everything the CommunityFundScreen needs about a borrower:
//   LOAN_REQUESTS   → current request details
//   PROFILES        → name, reputation, about
//   CREDIT_PROFILES → credit score, risk band
//   USER_BADGES     → earned + locked badges

import 'package:flutter/material.dart';

import 'badge_model.dart';

class BorrowerProfileModel {
  const BorrowerProfileModel({
    required this.loanRequestId,
    required this.borrowerId,
    required this.borrowerName,
    required this.about,
    required this.reputationScore,
    required this.creditScore,
    required this.riskBand,
    required this.amountRequested,
    required this.fundedAmount,
    required this.interestRate,
    required this.durationDays,
    required this.badges,
    this.purpose,
    this.avatarSeed,
  });

  final String loanRequestId;
  final String borrowerId;
  final String borrowerName;
  final String about;
  final int reputationScore;
  final int creditScore;

  /// 'low' | 'medium' | 'high'
  final String riskBand;

  final double amountRequested;
  final double fundedAmount;
  final double interestRate;
  final int durationDays;
  final List<BadgeModel> badges;
  final String? purpose;
  final int? avatarSeed;

  // Computed display properties 

  double get progress =>
      amountRequested == 0 ? 0 : fundedAmount / amountRequested;

  String get progressText => '${(progress * 100).round()}%';

  double get remainingAmount {
    final r = amountRequested - fundedAmount;
    return r < 0 ? 0 : r;
  }

  bool get isFullyFunded => remainingAmount <= 0;

  double get expectedReturn =>
      amountRequested * (1 + interestRate / 100);

  String get dueIn => '$durationDays days';

  String get subtitle =>
      '${riskBand[0].toUpperCase()}${riskBand.substring(1)} risk · '
      '$durationDays-day loan';

  String get scoreLabel {
    if (reputationScore >= 80) return 'Excellent';
    if (reputationScore >= 60) return 'Good';
    if (reputationScore >= 40) return 'Fair';
    return 'Building';
  }

  Color get scoreColor {
    if (reputationScore >= 80) return const Color(0xFF059669);
    if (reputationScore >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String get avatarUrl =>
      'https://api.dicebear.com/7.x/avataaars/png?seed=${avatarSeed ?? borrowerId}';

  // Serialisation 

  factory BorrowerProfileModel.fromJson(
    Map<String, dynamic> json,
    List<BadgeModel> badges,
  ) {
    final profile =
        json['profiles'] as Map<String, dynamic>?;
    final creditProfile =
        profile?['credit_profiles'] as Map<String, dynamic>?;

    return BorrowerProfileModel(
      loanRequestId: json['id'] as String,
      borrowerId: json['borrower_id'] as String,
      borrowerName:
          profile?['full_name'] as String? ?? 'Borrower',
      about: profile?['about'] as String? ??
          'This borrower has not added a profile description yet.',
      reputationScore:
          (profile?['reputation_score'] as num?)?.toInt() ?? 50,
      creditScore:
          (creditProfile?['credit_score'] as num?)?.toInt() ?? 0,
      riskBand:
          creditProfile?['risk_band'] as String? ?? 'medium',
      amountRequested:
          (json['amount_requested'] as num).toDouble(),
      fundedAmount:
          (json['funded_amount'] as num?)?.toDouble() ?? 0,
      interestRate: (json['interest_rate'] as num).toDouble(),
      durationDays: json['duration_days'] as int,
      purpose: json['purpose'] as String?,
      avatarSeed: (profile?['avatar_seed'] as num?)?.toInt(),
      badges: badges,
    );
  }
}