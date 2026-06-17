
// Data-layer providers for the loans feature.
//
// Dependency graph:
//   supabaseClientProvider  (defined globally in your app's provider file)
//       └── loanRepositoryProvider
//               ├── activeLoansProvider
//               └── myLoanRequestsProvider

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/active_loan_model.dart';
import '../models/loan_request_model.dart';
import '../repositories/loan_repository.dart';

// ── Infrastructure ──────────────────────────────────────────────────────────

/// Exposes the global Supabase client.
///
/// Override this in tests by providing a fake client via ProviderScope.
final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

// ── Repository ──────────────────────────────────────────────────────────────

/// Provides the [LoanRepository] singleton.
///
/// [autoDispose] keeps memory tidy when the loans feature is not mounted.
final loanRepositoryProvider = Provider.autoDispose<LoanRepository>((ref) {
  return LoanRepository(ref.watch(supabaseClientProvider));
});

// ── Data providers ──────────────────────────────────────────────────────────

/// Fetches active disbursed loans for the current borrower.
///
/// Screens that only need to read data watch this provider directly.
/// The view-model provider transforms it into business-ready state.
final activeLoansProvider =
    FutureProvider.autoDispose<List<ActiveLoanModel>>((ref) async {
  return ref.watch(loanRepositoryProvider).fetchMyActiveLoansAsBorrower();
});

/// Fetches all loan requests submitted by the current user.
final myLoanRequestsProvider =
    FutureProvider.autoDispose<List<LoanRequestModel>>((ref) async {
  return ref.watch(loanRepositoryProvider).fetchMyLoanRequests();
});

/// Fetches active community loan requests visible to any authenticated user.
final communityLoanRequestsProvider =
    FutureProvider.autoDispose<List<LoanRequestModel>>((ref) async {
  return ref.watch(loanRepositoryProvider).fetchActiveCommunityRequests();
});