class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.userId,
    this.loanRequestId,
    this.activeLoanId,
    required this.type,
    required this.grossAmount,
    required this.feeAmount,
    required this.netAmount,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String? loanRequestId;
  final String? activeLoanId;
  final String type; // 'funding' | 'repayment' | 'interest' | 'fee' | 'withdrawal' | 'deposit'
  final double grossAmount;
  final double feeAmount;
  final double netAmount;
  final String status; // 'pending' | 'completed' | 'failed'
  final DateTime createdAt;

  bool get isCredit => type == 'repayment' || type == 'deposit' || type == 'interest';

  String get displayTitle {
    switch (type) {
      case 'funding':
        return 'Loan funded';
      case 'repayment':
        return 'Repayment received';
      case 'interest':
        return 'Interest earned';
      case 'fee':
        return 'Platform fee';
      case 'withdrawal':
        return 'Withdrawal';
      case 'deposit':
        return 'Wallet top up';
      default:
        return type;
    }
  }

  String get amountText {
    final prefix = isCredit ? '+' : '-';
    return '$prefix${_formatPula(netAmount)}';
  }

  static String _formatPula(double amount) {
    final value = amount.abs();
    final whole = value.truncate();
    final fraction = ((value - whole) * 100).round();
    final digits = whole.toString();
    final buffer = StringBuffer('P');
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buffer.write(' ');
    }
    if (fraction > 0) {
      buffer.write('.${fraction.toString().padLeft(2, '0')}');
    }
    return buffer.toString();
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      loanRequestId: json['loan_request_id'] as String?,
      activeLoanId: json['active_loan_id'] as String?,
      type: json['type'] as String? ?? 'deposit',
      grossAmount: (json['gross_amount'] as num).toDouble(),
      feeAmount: (json['fee_amount'] as num?)?.toDouble() ?? 0,
      netAmount: (json['net_amount'] as num).toDouble(),
      status: json['status'] as String? ?? 'completed',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
