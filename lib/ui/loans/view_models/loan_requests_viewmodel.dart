// lib/ui/loans/view_models/loan_requests_view_model.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/loan_request_model.dart';
import '../../../data/providers/loan_providers.dart';

// ── UI State ──────────────────────────────────────────────────────────────────

/// Immutable snapshot of everything the Loan Requests section needs to render.
class LoanRequestsUiState {
  const LoanRequestsUiState({required this.requests});

  final List<LoanRequestModel> requests;

  int get totalCount => requests.length;

  int get activeCount =>
      requests.where((r) => r.status == 'active').length;
}

// ── Presentational helpers ────────────────────────────────────────────────────

/// Returns the brand colour for a given loan request status.
Color requestStatusColor(String status) {
  return switch (status) {
    'active' => const Color(0xFF0038FF),
    'funded' => const Color(0xFF059669),
    'repaying' => const Color(0xFF7C3AED),
    'completed' => const Color(0xFF6B7280),
    'cancelled' => const Color(0xFFEF4444),
    _ => const Color(0xFF9CA3AF),
  };
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

class LoanRequestsViewModel
    extends AutoDisposeAsyncNotifier<LoanRequestsUiState> {

  @override
  Future<LoanRequestsUiState> build() => _load();

  Future<LoanRequestsUiState> _load() async {
    final requests = await ref
        .watch(loanRepositoryProvider)
        .fetchMyLoanRequests();

    return LoanRequestsUiState(requests: requests);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final loanRequestsViewModelProvider = AsyncNotifierProvider.autoDispose<
    LoanRequestsViewModel, LoanRequestsUiState>(
  LoanRequestsViewModel.new,
);