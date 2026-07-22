
// Aggregates the current user's financial snapshot that Kutlo needs
// to give personalised, accurate advice.
//
// Sourced from:
//   PROFILES         → borrowing_limit, available_lending_amount
//   CREDIT_PROFILES  → credit_score, risk_band, approved_borrowing_limit
//   ACTIVE_LOANS     → count of active loans, total outstanding
//   LOAN_CONTRIBUTIONS → total amount deployed as a lender
//
// This context is serialised into Kutlo's system prompt so every response
// is grounded in the user's actual situation.

/// Financial context passed to Kutlo for personalised advice.
class KutloContextModel {
  const KutloContextModel({
    required this.userName,
    required this.availableBalance,
    required this.availableLendingAmount,
    required this.borrowingLimit,
    required this.creditScore,
    required this.riskBand,
    required this.approvedBorrowingLimit,
    required this.activeLoansCount,
    required this.totalOutstanding,
    required this.totalDeployed,
  });

  final String userName;

  /// Platform wallet balance (BWP).
  final double availableBalance;

  /// Amount the user can currently deploy as a lender.
  final double availableLendingAmount;

  /// Maximum the user is approved to borrow.
  final double borrowingLimit;

  // Credit profile
  final int creditScore;
  final String riskBand;
  final double approvedBorrowingLimit;

  // Loan activity
  final int activeLoansCount;
  final double totalOutstanding;
  final double totalDeployed;

  static const empty = KutloContextModel(
    userName: 'User',
    availableBalance: 0,
    availableLendingAmount: 0,
    borrowingLimit: 0,
    creditScore: 0,
    riskBand: 'unknown',
    approvedBorrowingLimit: 0,
    activeLoansCount: 0,
    totalOutstanding: 0,
    totalDeployed: 0,
  );

  // System prompt serialisation 

  /// Produces the financial context block injected into Kutlo's system prompt.
  String toSystemPromptBlock() {
    return '''
Current user financial snapshot (use this to give personalised advice):
- Name: $userName
- Wallet balance: P ${availableBalance.toStringAsFixed(2)}
- Available lending amount: P ${availableLendingAmount.toStringAsFixed(2)}
- Borrowing limit: P ${borrowingLimit.toStringAsFixed(2)}
- Credit score: $creditScore ($riskBand risk band)
- Approved borrowing limit: P ${approvedBorrowingLimit.toStringAsFixed(2)}
- Active loans as borrower: $activeLoansCount
- Total outstanding as borrower: P ${totalOutstanding.toStringAsFixed(2)}
- Total deployed as lender: P ${totalDeployed.toStringAsFixed(2)}
''';
  }

  // Deserialisation 

  factory KutloContextModel.fromJson(Map<String, dynamic> json) {
    return KutloContextModel(
      userName: json['user_name'] as String? ?? 'User',
      availableBalance:
          (json['available_balance'] as num?)?.toDouble() ?? 0,
      availableLendingAmount:
          (json['available_lending_amount'] as num?)?.toDouble() ?? 0,
      borrowingLimit:
          (json['borrowing_limit'] as num?)?.toDouble() ?? 0,
      creditScore: (json['credit_score'] as num?)?.toInt() ?? 0,
      riskBand: json['risk_band'] as String? ?? 'unknown',
      approvedBorrowingLimit:
          (json['approved_borrowing_limit'] as num?)?.toDouble() ?? 0,
      activeLoansCount:
          (json['active_loans_count'] as num?)?.toInt() ?? 0,
      totalOutstanding:
          (json['total_outstanding'] as num?)?.toDouble() ?? 0,
      totalDeployed:
          (json['total_deployed'] as num?)?.toDouble() ?? 0,
    );
  }
}