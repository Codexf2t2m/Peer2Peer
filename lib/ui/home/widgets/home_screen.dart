
// UC: View Available Lending Amount, View Monthly Statement,
//     View Borrowing Limit (overview), Browse Community Feed (entry),
//     Request Community Loan (entry), Financial Guidance (entry)
//
// Architecture
// • ConsumerWidget — zero local state.
// • Watches ONE AsyncValue<HomeOverviewModel> from homeViewModelProvider.
//   Previously: four separate providers each invalidated independently.
// • All bottom-sheet methods extracted to dedicated widget files.
// • RefreshIndicator calls vm.refresh() — one call reloads everything.
// • LoanPerformanceCard now receives live data from the VM instead of
//   hardcoded constants.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app_routes.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../data/providers/home_providers.dart';
import '../view_models/home_view_model.dart';
import 'home_action_button.dart';
import 'home_header.dart';
import 'home_notifications_sheet.dart';
import 'home_overview_sheet.dart';
import 'home_search_sheet.dart';
import 'home_transactions_sheet.dart';
import 'loan_performance_card.dart';
import 'overview_cards.dart';
import 'recent_transactions_card.dart';
import 'stacked_card_carousel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(homeViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 24,
        title: uiState.when(
          data: (overview) => HomeHeader(
            displayName: overview.displayName,
            hasUnreadNotifications:
                overview.hasUnreadNotifications,
            onSearch: () => HomeSearchSheet.show(
              context,
              repository:
                  ref.read(homeRepositoryProvider),
            ),
            onNotifications: () =>
                HomeNotificationsSheet.show(
              context,
              notifications: overview.notifications,
            ),
          ),
          loading: () => HomeHeader(
            displayName: '',
            hasUnreadNotifications: false,
            onSearch: () {},
            onNotifications: () {},
          ),
          error: (_, _) => HomeHeader(
            displayName: '',
            hasUnreadNotifications: false,
            onSearch: () {},
            onNotifications: () {},
          ),
        ),
        toolbarHeight: 70,
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(homeViewModelProvider.notifier).refresh(),
          child: uiState.when(
            // ── Loading ──────────────────────────────────────
            loading: () => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                  24, 8, 24, 24),
              children: const [
                StackedCardCarousel(),
                SizedBox(height: 60),
                Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2)),
              ],
            ),

            // ── Error ────────────────────────────────────────
            error: (e, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                  24, 8, 24, 24),
              children: [
                const StackedCardCarousel(),
                const SizedBox(height: 30),
                AppCard(
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFEF4444)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.toString().replaceFirst(
                              'Exception: ', ''),
                          style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () => ref
                            .read(homeViewModelProvider
                                .notifier)
                            .refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Data ─────────────────────────────────────────
            data: (overview) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                  24, 8, 24, 24),
              children: [
                // ── Card carousel ─────────────────────────
                const StackedCardCarousel(),
                const SizedBox(height: 30),

                // ── Quick actions ─────────────────────────
                const SectionTitle(title: 'Quick actions'),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: HomeActionButton(
                        label: 'Request',
                        filled: true,
                        icon: HugeIcons
                            .strokeRoundedMoneyReceiveSquare,
                        onTap: () =>
                            Navigator.of(context)
                                .pushNamed(
                                    AppRoutes.request),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: HomeActionButton(
                        label: 'Ask Kutlo',
                        filled: false,
                        icon: HugeIcons
                            .strokeRoundedAiMagic,
                        onTap: () =>
                            Navigator.of(context)
                                .pushNamed(
                                    AppRoutes.askKutlo),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Overview cards ────────────────────────
                SectionTitle(
                  title: 'Your Overview',
                  trailing: TextButton(
                    onPressed: () =>
                        HomeOverviewSheet.show(
                      context,
                      overview: overview,
                    ),
                    child: const Text('View all'),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OverviewCard(
                        title: 'Total lent',
                        value: _pula(overview.totalLent),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: OverviewCard(
                        title: 'Interest earned',
                        value: _pula(
                            overview.interestEarned),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Loan performance ──────────────────────
                LoanPerformanceCard(
                  ratePercent:
                      overview.repaymentRatePercent,
                  monthlyDelta:
                      overview.monthlyDeltaPula.round(),
                ),
                const SizedBox(height: 26),

                // ── Recent transactions ───────────────────
                SectionTitle(
                  title: 'Recent Transactions',
                  trailing: TextButton(
                    onPressed: () =>
                        HomeTransactionsSheet.show(
                      context,
                      title: 'All activity',
                      transactions:
                          overview.allTransactions,
                    ),
                    child: const Text('View all'),
                  ),
                ),
                const SizedBox(height: 14),
                if (overview.recentTransactions.isEmpty)
                  const AppCard(
                    child: Text(
                      'No transactions yet. Fund someone '
                      'or top up your wallet to get started.',
                    ),
                  )
                else
                  RecentTransactionsCard(
                    transactions:
                        overview.recentTransactions,
                  ),

                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          const BottomNavBar(currentRoute: AppRoutes.home),
    );
  }

  static String _pula(double amount) =>
      'P ${amount.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+\.)'),
            (m) => '${m[1]},',
          )}';
}