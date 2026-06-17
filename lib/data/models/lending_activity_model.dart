
// Maps to TRANSACTIONS rows where type is 'funding' or 'repayment',
// joined with LOAN_REQUESTS (purpose) and PROFILES (borrower name).
//
// The existing screen used the generic AppTransaction model and filtered
// by category.  This dedicated model gives the lend feature its own
// typed contract and removes the dependency on a shared transaction type.

/// Represents a single lending activity event shown on the Lend screen.
///
/// An activity is either a loan funded by the lender ('funding') or a
/// repayment received back from a borrower ('repayment').
class LendingActivityModel {
  const LendingActivityModel({
    required this.id,
    required this.type,
    required this.grossAmount,
    required this.netAmount,
    required this.feeAmount,
    required this.status,
    required this.createdAt,
    this.loanPurpose,
    this.borrowerName,
    this.activeLoanId,
    this.loanRequestId,
  });

  final String id;

  /// 'funding' | 'repayment'
  final String type;

  final double grossAmount;
  final double netAmount;
  final double feeAmount;
  final String status;
  final DateTime createdAt;

  // Joined fields
  final String? loanPurpose;
  final String? borrowerName;
  final String? activeLoanId;
  final String? loanRequestId;

  // ── Computed ────────────────────────────────────────────────────────────────

  bool get isRepayment => type == 'repayment';
  bool get isFunding => type == 'funding';

  /// Label used in the tile subtitle.
  String get typeLabel => isRepayment ? 'Repaid' : 'Active';

  /// Display name for the counterparty.
  String get displayBorrowerName =>
      borrowerName?.trim().isNotEmpty == true ? borrowerName! : 'Borrower';

  /// Tile title: purpose if available, otherwise a generic label.
  String get tileTitle =>
      loanPurpose?.trim().isNotEmpty == true
          ? loanPurpose!
          : (isRepayment ? 'Repayment received' : 'Loan funded');

  // ── Serialisation ───────────────────────────────────────────────────────────

  factory LendingActivityModel.fromJson(Map<String, dynamic> json) {
    final loanRequest =
        json['loan_requests'] as Map<String, dynamic>?;
    final profile =
        loanRequest?['profiles'] as Map<String, dynamic>?;

    return LendingActivityModel(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'funding',
      grossAmount: (json['gross_amount'] as num).toDouble(),
      netAmount: (json['net_amount'] as num).toDouble(),
      feeAmount: (json['fee_amount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      loanPurpose: loanRequest?['purpose'] as String?,
      borrowerName: profile?['full_name'] as String?,
      activeLoanId: json['active_loan_id'] as String?,
      loanRequestId: json['loan_request_id'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LendingActivityModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}