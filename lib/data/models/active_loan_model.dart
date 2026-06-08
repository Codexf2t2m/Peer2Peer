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
  final double principal;
  final double totalRepaymentAmount;
  final DateTime dueDate;
  final String status; // 'active' | 'default' | 'completed'
  final DateTime createdAt;
  final String? loanPurpose;

  bool get isOverdue =>
      status == 'active' && dueDate.isBefore(DateTime.now());

  int get daysRemaining => dueDate.difference(DateTime.now()).inDays;

  factory ActiveLoanModel.fromJson(Map<String, dynamic> json) {
    final loanRequest =
        json['loan_requests'] as Map<String, dynamic>?;

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
}
