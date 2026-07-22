
// Maps to the aggregated view of a lender's LOAN_CONTRIBUTIONS and
// ACTIVE_LOANS rows.  This is computed server-side (via a Supabase RPC
// or view) and returned as a single record — we model it explicitly
// so the UI never receives a raw Map<String,dynamic>.

/// Immutable snapshot of a lender's portfolio summary.
class LendingOverviewModel {
  const LendingOverviewModel({
    required this.totalLent,
    required this.totalExpectedReturn,
    required this.activeContributionsCount,
    required this.completedContributionsCount,
  });

  /// Total principal deployed by this lender (BWP).
  final double totalLent;

  /// Sum of expected returns across all active contributions.
  final double totalExpectedReturn;

  final int activeContributionsCount;
  final int completedContributionsCount;

  // Computed 

  /// Projected net profit across the entire portfolio.
  double get projectedProfit => totalExpectedReturn - totalLent;

  /// True when the lender has at least one active deployment.
  bool get hasActiveLoans => activeContributionsCount > 0;

  // Zero state 

  static const empty = LendingOverviewModel(
    totalLent: 0,
    totalExpectedReturn: 0,
    activeContributionsCount: 0,
    completedContributionsCount: 0,
  );

  // Serialisation 

  factory LendingOverviewModel.fromJson(Map<String, dynamic> json) {
    return LendingOverviewModel(
      totalLent:
          (json['total_lent'] as num?)?.toDouble() ?? 0,
      totalExpectedReturn:
          (json['total_expected_return'] as num?)?.toDouble() ?? 0,
      activeContributionsCount:
          (json['active_contributions_count'] as num?)?.toInt() ?? 0,
      completedContributionsCount:
          (json['completed_contributions_count'] as num?)?.toInt() ?? 0,
    );
  }
}