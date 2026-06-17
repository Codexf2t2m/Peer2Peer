// Owns:
//   • [LendUiState] — the complete snapshot the screen renders from
//   • refresh() — wired to the RefreshIndicator
//   • Presentational helpers (colors, labels) as top-level functions
//     so widget tests can assert on them without a provider setup

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/lending_activity_model.dart';
import '../../../data/models/lending_overview_model.dart';
import '../../../data/providers/lend_providers.dart';

// UI State

/// Everything [LendScreen] needs to render — fetched, filtered, and shaped.
class LendUiState {
  const LendUiState({
    required this.overview,
    required this.recentActivity,
    required this.allActivity,
  });

  final LendingOverviewModel overview;

  /// The 4 most recent lending activities shown on the main screen.
  final List<LendingActivityModel> recentActivity;

  /// Full activity list for the "View all" bottom sheet.
  final List<LendingActivityModel> allActivity;

  bool get hasActivity => allActivity.isNotEmpty;
}

// Presentational helpers

/// Icon background color for a lending activity tile.
Color activityIconColor(LendingActivityModel activity) {
  return activity.isRepayment
      ? const Color(0xFF059669) // green — money came back
      : const Color(0xFF0038FF); // blue  — money went out
}

/// Amount text color for a lending activity tile.
Color activityAmountColor(LendingActivityModel activity) {
  return activity.isRepayment
      ? const Color(0xFF059669)
      : const Color(0xFF1E1E1E);
}

/// Formatted sign + amount string (e.g. "+P 1,200.00" / "P 800.00").
String activityAmountText(LendingActivityModel activity) {
  final prefix = activity.isRepayment ? '+' : '';
  return '$prefix${_formatPula(activity.grossAmount)}';
}

String _formatPula(double amount) {
  // Delegates to the app's shared formatter; replicated here so the helper
  // is self-contained for tests. Replace with your formatPula() import.
  return 'P ${amount.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+\.)'),
        (m) => '${m[1]},',
      )}';
}

// ViewModel 

class LendViewModel extends AutoDisposeAsyncNotifier<LendUiState> {
  static const _recentLimit = 4;

  @override
  Future<LendUiState> build() => _load();

  Future<LendUiState> _load() async {
    // Run both fetches concurrently.
    final results = await Future.wait([
      ref.watch(lendRepositoryProvider).fetchLendingOverview(),
      ref.watch(lendRepositoryProvider).fetchLendingActivity(),
    ]);

    final overview = results[0] as LendingOverviewModel;
    final all = results[1] as List<LendingActivityModel>;

    return LendUiState(
      overview: overview,
      recentActivity: all.take(_recentLimit).toList(),
      allActivity: all,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

// Provider 

final lendViewModelProvider =
    AsyncNotifierProvider.autoDispose<LendViewModel, LendUiState>(
  LendViewModel.new,
);