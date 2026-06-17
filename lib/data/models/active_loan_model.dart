// lib/data/models/active_loan_model.dart

/// Represents a disbursed loan where the current user is the borrower.
///
/// Maps to the `active_loans` table joined with `loan_requests` for purpose.
/// All business-rule computed properties live here so both the repository
/// and the view model can rely on them without re-implementing the logic.
class ActiveLoanModel {
  const ActiveLoanModel({
    required this.id,
    required this.loanRequestId,
    required this.borrowerId,
    required this.principal,
    required this.totalRepaymentAmount,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    this.loanPurpose,
  });

  final String id;
  final String loanRequestId;
  final String borrowerId;

  /// The original disbursed amount (BWP).
  final double principal;

  /// Principal + interest the borrower must repay in full.
  final double totalRepaymentAmount;

  final DateTime dueDate;

  /// 'active' | 'default' | 'completed'
  final String status;

  final DateTime createdAt;
  final String? loanPurpose;

  // ── Computed properties ───────────────────────────────────────────────────

  /// True when the loan is still active but the due date has passed.
  bool get isOverdue =>
      status == 'active' && dueDate.isBefore(DateTime.now());

  /// Positive = days until due. Negative = days past due.
  int get daysRemaining => dueDate.difference(DateTime.now()).inDays;

  /// Interest charged expressed as a flat amount.
  double get interestAmount => totalRepaymentAmount - principal;

  // ── Serialisation ─────────────────────────────────────────────────────────

  factory ActiveLoanModel.fromJson(Map<String, dynamic> json) {
    final loanRequest = json['loan_requests'] as Map<String, dynamic>?;

    return ActiveLoanModel(
      id: json['id'] as String,
      loanRequestId: json['loan_request_id'] as String,
      borrowerId: json['borrower_id'] as String,
      principal: (json['principal'] as num).toDouble(),
      totalRepaymentAmount:
          (json['total_repayment_amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['due_date'] as String),
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['created_at'] as String),
      loanPurpose: loanRequest?['purpose'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveLoanModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}