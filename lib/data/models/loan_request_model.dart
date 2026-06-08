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
    // Joined fields (populated via select with borrower profile)
    this.borrowerFullName,
    this.borrowerEmail,
    this.borrowerReputationScore,
    this.borrowerAvatarSeed,
  });

  final String id;
  final String borrowerId;
  final String requestType; // 'community' | 'direct'
  final String? targetLenderId;
  final double amountRequested;
  final double interestRate;
  final int durationDays;
  final String? purpose;
  final String status;
  final double fundedAmount;
  final DateTime createdAt;

  // Joined from profiles
  final String? borrowerFullName;
  final String? borrowerEmail;
  final String? borrowerReputationScore;
  final int? borrowerAvatarSeed;

  double get progress =>
      amountRequested == 0 ? 0 : fundedAmount / amountRequested;

  double get remainingAmount {
    final remaining = amountRequested - fundedAmount;
    return remaining < 0 ? 0 : remaining;
  }

  String get progressText => '${(progress * 100).round()}%';

  double get expectedReturn => amountRequested * (1 + interestRate / 100);

  String get dueIn => '$durationDays days';

  String get displayName {
    if (borrowerFullName != null && borrowerFullName!.trim().isNotEmpty) {
      return borrowerFullName!.trim();
    }
    if (borrowerEmail != null) {
      final name = borrowerEmail!.split('@').first.trim();
      if (name.isNotEmpty) {
        return '${name[0].toUpperCase()}${name.substring(1)}';
      }
    }
    return 'Borrower';
  }

  factory LoanRequestModel.fromJson(Map<String, dynamic> json) {
    // Handle joined profile data from nested select
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
      borrowerReputationScore: profile?['reputation_score'] as String?,
    );
  }
}
