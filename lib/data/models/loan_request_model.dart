// lib/data/models/loan_request_model.dart

/// Represents a borrower's loan request record.
///
/// Maps to the `loan_requests` table. When fetched with a profile join,
/// borrower display fields are populated; otherwise they remain null.
class LoanRequestModel {
  const LoanRequestModel({
    required this.id,
    required this.borrowerId,
    required this.requestType,
    this.targetLenderId,
    required this.amountRequested,
    required this.interestRate,
    required this.durationDays,
    this.purpose,
    required this.status,
    required this.fundedAmount,
    required this.createdAt,
    this.borrowerFullName,
    this.borrowerEmail,
    this.borrowerReputationScore,
  });

  final String id;
  final String borrowerId;

  /// 'community' | 'direct'
  final String requestType;
  final String? targetLenderId;

  final double amountRequested;

  /// Annual interest rate expressed as a percentage (e.g. 5.0 = 5 %).
  final double interestRate;

  final int durationDays;
  final String? purpose;

  /// 'active' | 'funded' | 'repaying' | 'completed' | 'cancelled'
  final String status;

  final double fundedAmount;
  final DateTime createdAt;

  // Joined from profiles (nullable when fetched without join)
  final String? borrowerFullName;
  final String? borrowerEmail;
  final String? borrowerReputationScore;

  // ── Computed properties ───────────────────────────────────────────────────

  double get progress =>
      amountRequested == 0 ? 0 : fundedAmount / amountRequested;

  double get remainingAmount {
    final r = amountRequested - fundedAmount;
    return r < 0 ? 0 : r;
  }

  String get progressText => '${(progress * 100).round()}%';

  double get expectedReturn => amountRequested * (1 + interestRate / 100);

  /// Resolves the best available display name for the borrower.
  String get displayName {
    if (borrowerFullName != null && borrowerFullName!.trim().isNotEmpty) {
      return borrowerFullName!.trim();
    }
    if (borrowerEmail != null) {
      final local = borrowerEmail!.split('@').first.trim();
      if (local.isNotEmpty) {
        return '${local[0].toUpperCase()}${local.substring(1)}';
      }
    }
    return 'Borrower';
  }

  // ── Serialisation ─────────────────────────────────────────────────────────

  factory LoanRequestModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;

    return LoanRequestModel(
      id: json['id'] as String,
      borrowerId: json['borrower_id'] as String,
      requestType: json['request_type'] as String? ?? 'community',
      targetLenderId: json['target_lender_id'] as String?,
      amountRequested: (json['amount_requested'] as num).toDouble(),
      interestRate: (json['interest_rate'] as num).toDouble(),
      durationDays: json['duration_days'] as int,
      purpose: json['purpose'] as String?,
      status: json['status'] as String? ?? 'active',
      fundedAmount: (json['funded_amount'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      borrowerFullName: profile?['full_name'] as String?,
      borrowerEmail: profile?['email'] as String?,
      borrowerReputationScore:
          profile?['reputation_score']?.toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanRequestModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  Null get dueIn => null;
}