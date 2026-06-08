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
    // Joined fields
    this.borrowerName,
    this.loanPurpose,
    this.loanDueDate,
  });

  final String id;
  final String loanRequestId;
  final String lenderId;
  final double amountContributed;
  final double expectedReturn;
  final double platformCut;
  final String status; // 'pending' | 'funded' | 'repaying' | 'completed'
  final DateTime createdAt;

  // Joined
  final String? borrowerName;
  final String? loanPurpose;
  final DateTime? loanDueDate;

  double get netProfit => expectedReturn - amountContributed - platformCut;

  factory LoanContributionModel.fromJson(Map<String, dynamic> json) {
    final loanRequest =
        json['loan_requests'] as Map<String, dynamic>?;
    final borrowerProfile =
        loanRequest?['profiles'] as Map<String, dynamic>?;

    return LoanContributionModel(
      id: json['id'] as String,
      loanRequestId: json['loan_request_id'] as String,
      lenderId: json['lender_id'] as String,
      amountContributed: (json['amount_contributed'] as num).toDouble(),
      expectedReturn: (json['expected_return'] as num).toDouble(),
      platformCut: (json['platform_cut'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      borrowerName: borrowerProfile?['full_name'] as String? ??
          borrowerProfile?['email'] as String?,
      loanPurpose: loanRequest?['purpose'] as String?,
    );
  }
}
