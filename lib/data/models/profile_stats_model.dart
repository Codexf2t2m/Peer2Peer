
// Aggregated borrower/lender activity stats shown on the profile screen.
//
// Sourced from a Supabase RPC or view that aggregates:
//   LOAN_REQUESTS     → total_requested
//   ACTIVE_LOANS      → fully_repaid (status = 'completed')
//   LOAN_CONTRIBUTIONS→ people_funded
//   TRANSACTIONS      → late_payments proxy

/// Immutable snapshot of the user's activity statistics.
class ProfileStatsModel {
  const ProfileStatsModel({
    required this.totalRequested,
    required this.fullyRepaid,
    required this.peopleFunded,
    required this.latePayments,
  });

  final int totalRequested;
  final int fullyRepaid;
  final int peopleFunded;
  final int latePayments;

  static const empty = ProfileStatsModel(
    totalRequested: 0,
    fullyRepaid: 0,
    peopleFunded: 0,
    latePayments: 0,
  );

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) {
    return ProfileStatsModel(
      totalRequested:
          (json['total_requested'] as num?)?.toInt() ?? 0,
      fullyRepaid:
          (json['fully_repaid'] as num?)?.toInt() ?? 0,
      peopleFunded:
          (json['people_funded'] as num?)?.toInt() ?? 0,
      latePayments:
          (json['late_payments'] as num?)?.toInt() ?? 0,
    );
  }
}