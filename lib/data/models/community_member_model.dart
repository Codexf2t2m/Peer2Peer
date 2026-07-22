
// Domain model for a borrower visible on the community feed.
//
// Sourced from LOAN_REQUESTS joined with PROFILES and CREDIT_PROFILES:
//   LOAN_REQUESTS  → amount_requested, funded_amount, interest_rate,
//                    duration_days, purpose, status, created_at
//   PROFILES       → full_name, reputation_score, avatar_seed
//   CREDIT_PROFILES→ credit_score, risk_band

import 'package:flutter/material.dart';

class CommunityMemberModel {
  const CommunityMemberModel({
    required this.loanRequestId,
    required this.borrowerId,
    required this.borrowerName,
    required this.amountRequested,
    required this.fundedAmount,
    required this.interestRate,
    required this.durationDays,
    required this.purpose,
    required this.status,
    required this.createdAt,
    required this.reputationScore,
    required this.creditScore,
    required this.riskBand,
    this.avatarSeed,
  });

  final String loanRequestId;
  final String borrowerId;
  final String borrowerName;
  final double amountRequested;
  final double fundedAmount;
  final double interestRate;
  final int durationDays;
  final String? purpose;
  final String status;
  final DateTime createdAt;
  final int reputationScore;
  final int creditScore;

  /// 'low' | 'medium' | 'high'
  final String riskBand;

  /// Seed used to generate a deterministic avatar URL.
  final int? avatarSeed;

  // Computed display properties 

  double get progress =>
      amountRequested == 0 ? 0 : fundedAmount / amountRequested;

  String get progressText => '${(progress * 100).round()}%';

  double get remainingAmount {
    final r = amountRequested - fundedAmount;
    return r < 0 ? 0 : r;
  }

  double get expectedReturn =>
      amountRequested * (1 + interestRate / 100);

  String get dueIn => '$durationDays days';

  bool get hasBeenFunded => fundedAmount > 0;

  String get fundButtonLabel =>
      hasBeenFunded ? 'Fund More' : 'Fund First';

  String get subtitle =>
      '${riskBand[0].toUpperCase()}${riskBand.substring(1)} risk · '
      '$durationDays-day loan';

  String get requestDescription =>
      purpose?.isNotEmpty == true
          ? purpose!
          : 'Community loan request for ${_formatPula(amountRequested)}.';

  String get avatarUrl =>
      'https://api.dicebear.com/7.x/avataaars/png?seed=${avatarSeed ?? borrowerId}';

  //  Filter flags 

  /// Reputation score ≥ 80 qualifies as high trust.
  bool get isHighTrust => reputationScore >= 80;

  /// Duration ≤ 14 days qualifies as quick return.
  bool get isQuickReturn => durationDays <= 14;

  // Score display 

  int get score => reputationScore;

  Color get scoreColor {
    if (reputationScore >= 80) return const Color(0xFF059669);
    if (reputationScore >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  // ── Serialisation ─────────────────────────────────────────────────────────

  factory CommunityMemberModel.fromJson(Map<String, dynamic> json) {
    final profile =
        json['profiles'] as Map<String, dynamic>?;
    final creditProfile =
        profile?['credit_profiles'] as Map<String, dynamic>?;

    return CommunityMemberModel(
      loanRequestId: json['id'] as String,
      borrowerId: json['borrower_id'] as String,
      borrowerName: profile?['full_name'] as String? ?? 'Borrower',
      amountRequested:
          (json['amount_requested'] as num).toDouble(),
      fundedAmount:
          (json['funded_amount'] as num?)?.toDouble() ?? 0,
      interestRate:
          (json['interest_rate'] as num).toDouble(),
      durationDays: json['duration_days'] as int,
      purpose: json['purpose'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['created_at'] as String),
      reputationScore:
          (profile?['reputation_score'] as num?)?.toInt() ?? 50,
      creditScore:
          (creditProfile?['credit_score'] as num?)?.toInt() ?? 0,
      riskBand:
          creditProfile?['risk_band'] as String? ?? 'medium',
      avatarSeed:
          (profile?['avatar_seed'] as num?)?.toInt(),
    );
  }

  static String _formatPula(double amount) =>
      'P ${amount.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+\.)'),
            (m) => '${m[1]},',
          )}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommunityMemberModel &&
          runtimeType == other.runtimeType &&
          loanRequestId == other.loanRequestId;

  @override
  int get hashCode => loanRequestId.hashCode;
}