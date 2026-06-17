// lib/ui/loans/view_models/active_loans_view_model.dart
//
// Follows the Flutter architecture case study:
//   https://docs.flutter.dev/app-architecture/case-study/ui-layer
//
// Key decisions
// ─────────────
// • Extends AsyncNotifier<ActiveLoansUiState> so the VM owns both the data
//   AND its async lifecycle (loading / error / data).  The screen never calls
//   .when() on a raw FutureProvider — it consumes pre-shaped UI state.
//
// • The repository is injected through the Riverpod graph; the VM never
//   imports Supabase or any network package.
//
// • All presentational logic (colors, labels, progress) lives here, not in
//   widgets.  Widgets stay pure render trees.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/active_loan_model.dart';
import '../../../data/providers/loan_providers.dart';

// ── UI State ─────────────────────────────────────────────────────────────────

/// Immutable snapshot of everything [ActiveLoansScreen] needs to render.
///
/// Separating this from the VM class makes unit-testing trivial: construct
/// the state object directly and assert on its properties.
class ActiveLoansUiState {
  const ActiveLoansUiState({
    required this.loans,
  });

  final List<ActiveLoanModel> loans;

  // ── Derived counts ──────────────────────────────────────────────────────

  int get totalCount => loans.length;

  int get overdueCount =>
      loans.where((l) => l.isOverdue).length;

  bool get hasOverdue => overdueCount > 0;
}

// ── Presentational helpers ────────────────────────────────────────────────────
//
// These are pure functions / extension methods rather than inline ternaries
// so they can be unit-tested independently.

/// Returns the display colour for a loan's status badge.
Color loanStatusColor(ActiveLoanModel loan) {
  if (loan.isOverdue) return const Color(0xFFEF4444);
  return switch (loan.status) {
    'active' => const Color(0xFF059669),
    'completed' => const Color(0xFF6B7280),
    'default' => const Color(0xFFEF4444),
    _ => const Color(0xFF6B7280),
  };
}

/// Returns the display label for the status badge.
String loanStatusLabel(ActiveLoanModel loan) =>
    loan.isOverdue ? 'OVERDUE' : loan.status.toUpperCase();

/// Repayment progress: how much of the interest has been "earned back"
/// relative to the total obligation. Returns 0–1 clamped.
///
/// Formula: interest portion paid = (totalRepayment - principal) / totalRepayment
/// This is a reasonable proxy when a separate `amountRepaid` column is absent.
double loanRepaymentProgress(ActiveLoanModel loan) {
  if (loan.totalRepaymentAmount <= 0) return 0.0;
  final interestFraction =
      (loan.totalRepaymentAmount - loan.principal) /
          loan.totalRepaymentAmount;
  return interestFraction.clamp(0.0, 1.0);
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

/// Manages loading, refreshing, and state for the Active Loans screen.
///
/// The [AsyncNotifier] base class gives us:
///   • [state] as [AsyncValue<ActiveLoansUiState>] — consumed directly by the
///     screen widget via [activeLoansViewModelProvider].
///   • [ref] for accessing the repository without tight coupling.
class ActiveLoansViewModel
    extends AutoDisposeAsyncNotifier<ActiveLoansUiState> {

  @override
  Future<ActiveLoansUiState> build() => _load();

  Future<ActiveLoansUiState> _load() async {
    final loans = await ref
        .watch(loanRepositoryProvider)
        .fetchMyActiveLoansAsBorrower();

    return ActiveLoansUiState(loans: loans);
  }

  /// Invalidates cached data and reloads from the repository.
  ///
  /// Called by the screen's [RefreshIndicator].
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final activeLoansViewModelProvider = AsyncNotifierProvider.autoDispose<
    ActiveLoansViewModel, ActiveLoansUiState>(
  ActiveLoansViewModel.new,
);