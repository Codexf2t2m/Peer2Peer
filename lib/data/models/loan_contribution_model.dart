// lib/data/models/loan_contribution_model.dart

/// Represents a lender's funding contribution toward a loan request.
///
/// Maps to the `loan_contributions` table, optionally joined with
/// `loan_requests` and the borrower `profiles`.
class LoanContributionModel {
  const LoanContributionModel({
    required this.id,
    required this.loanRequestId,
    required this.lenderId,
    required this.amountContributed,
    required this.expectedReturn,
    required this.platformCut,
    required this.status,
    required this.createdAt,
    this.borrowerName,
    this.loanPurpose,
    this.loanDueDate,
  });

  final String id;
  final String loanRequestId;
  final String lenderId;

  final double amountContributed;

  /// The total amount the lender expects back (principal + interest share).
  final double expectedReturn;

  /// Platform fee already deducted from the lender's return.
  final double platformCut;

  /// 'pending' | 'funded' | 'repaying' | 'completed'
  final String status;

  final DateTime createdAt;

  // Joined
  final String? borrowerName;
  final String? loanPurpose;
  final DateTime? loanDueDate;

  // ── Computed properties ───────────────────────────────────────────────────

  /// Net profit after the platform fee.
  double get netProfit =>
      expectedReturn - amountContributed - platformCut;

  // ── Serialisation ─────────────────────────────────────────────────────────

  factory LoanContributionModel.fromJson(Map<String, dynamic> json) {
    final loanRequest =
        json['loan_requests'] as Map<String, dynamic>?;
    final borrowerProfile =
        loanRequest?['profiles'] as Map<String, dynamic>?;

    return LoanContributionModel(
      id: json['id'] as String,
      loanRequestId: json['loan_request_id'] as String,
      lenderId: json['lender_id'] as String,
      amountContributed:
          (json['amount_contributed'] as num).toDouble(),
      expectedReturn: (json['expected_return'] as num).toDouble(),
      platformCut: (json['platform_cut'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      borrowerName: borrowerProfile?['full_name'] as String? ??
          borrowerProfile?['email'] as String?,
      loanPurpose: loanRequest?['purpose'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanContributionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}