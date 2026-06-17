// UC14 – View Active Loans
//
// Architecture notes
// ──────────────────
// • The screen watches [activeLoansViewModelProvider] and
//   [loanRequestsViewModelProvider] only — never raw data providers.
//   This means the screen consumes pre-shaped [AsyncValue<UiState>] objects
//   whose loading / error / data states are owned by the VM, not the view.
//
// • [RefreshIndicator] calls vm.refresh() on each notifier, which resets
//   state to AsyncLoading and re-fetches from the repository.
//
// • Sub-widgets ([ActiveLoanCard], [LoanRequestCard]) receive typed domain
//   models, not view models.  Presentational helpers are free functions
//   imported from the vm files.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/app_back_button.dart';
import '../view_models/active_loans_viewmodel.dart';
import '../view_models/loan_requests_viewmodel.dart';
import 'active_loan_card.dart';
import 'loan_request_card.dart';
import 'shared_widgets.dart';

class ActiveLoansScreen extends ConsumerWidget {
  const ActiveLoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLoansState =
        ref.watch(activeLoansViewModelProvider);
    final loanRequestsState =
        ref.watch(loanRequestsViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: const AppBackButton(),
        title: const Text(
          'My Loans',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Both notifiers own their own reload logic.
          await Future.wait([
            ref
                .read(activeLoansViewModelProvider.notifier)
                .refresh(),
            ref
                .read(loanRequestsViewModelProvider.notifier)
                .refresh(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 8),
          children: [
            // ── Active Loans ─────────────────────────────────────────
            activeLoansState.when(
              loading: () => const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Active Loans',
                    icon: Icons.payments_outlined,
                  ),
                  SizedBox(height: 12),
                  LoadingSection(),
                ],
              ),
              error: (e, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Active Loans',
                    icon: Icons.payments_outlined,
                  ),
                  const SizedBox(height: 12),
                  ErrorCard(
                    message: e.toString(),
                    onRetry: () => ref
                        .read(activeLoansViewModelProvider.notifier)
                        .refresh(),
                  ),
                ],
              ),
              data: (uiState) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Active Loans',
                    icon: Icons.payments_outlined,
                    badge: uiState.hasOverdue
                        ? '${uiState.overdueCount} overdue'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  if (uiState.loans.isEmpty)
                    const EmptyCard(
                      icon: Icons.check_circle_outline,
                      message: 'No active loans — all clear!',
                    )
                  else
                    ...uiState.loans.map(
                      (loan) => ActiveLoanCard(loan: loan),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Loan Request History ──────────────────────────────────
            loanRequestsState.when(
              loading: () => const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Loan Request History',
                    icon: Icons.history_rounded,
                  ),
                  SizedBox(height: 12),
                  LoadingSection(),
                ],
              ),
              error: (e, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Loan Request History',
                    icon: Icons.history_rounded,
                  ),
                  const SizedBox(height: 12),
                  ErrorCard(
                    message: e.toString(),
                    onRetry: () => ref
                        .read(loanRequestsViewModelProvider.notifier)
                        .refresh(),
                  ),
                ],
              ),
              data: (uiState) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Loan Request History',
                    icon: Icons.history_rounded,
                  ),
                  const SizedBox(height: 12),
                  if (uiState.requests.isEmpty)
                    const EmptyCard(
                      icon: Icons.inbox_outlined,
                      message:
                          "You haven't submitted any loan requests yet.",
                    )
                  else
                    ...uiState.requests.map(
                      (request) =>
                          LoanRequestCard(request: request),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}