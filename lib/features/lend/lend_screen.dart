import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../app_routes.dart';
import '../../../app_state.dart';
import '../../../data/providers/data_providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../ui/app_theme.dart';

class LendScreen extends ConsumerWidget {
  const LendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lendingOverviewAsync = ref.watch(lendingOverviewProvider);
    final transactionsAsync = ref.watch(transactionsProvider);

    final lendingActivity = transactionsAsync.valueOrNull
            ?.where(
              (transaction) =>
                  transaction.category == TransactionCategory.funding ||
                  transaction.category == TransactionCategory.repayment,
            )
            .toList() ??
        [];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Text('Lend', style: Theme.of(context).textTheme.titleMedium),
        actions: [
          IconButton(
            tooltip: 'New request',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.request),
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedAddSquare,
              color: AppTheme.iconColor,
              size: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(lendingOverviewProvider);
            ref.invalidate(transactionsProvider);
            await ref.read(lendingOverviewProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            children: [
              const SectionTitle(title: 'Your lending'),
              const SizedBox(height: 12),
              AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Outstanding',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lendingOverviewAsync.maybeWhen(
                            data: (overview) => formatPula(overview['total_lent'] ?? 0),
                            orElse: () => 'P0',
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.community),
                      child: const Text('Lend now'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SectionTitle(
                title: 'Active loans',
                trailing: TextButton(
                  onPressed: () => _showLoanHistory(context, lendingActivity),
                  child: const Text('View all'),
                ),
              ),
              const SizedBox(height: 12),
              transactionsAsync.when(
                data: (_) {
                  if (lendingActivity.isEmpty) {
                    return const AppCard(child: Text('No lending activity yet.'));
                  }
                  return Column(
                    children: lendingActivity
                        .take(4)
                        .map(
                          (transaction) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _LoanTile(transaction: transaction),
                          ),
                        )
                        .toList(),
                  );
                },
                error: (err, _) => AppCard(child: Text('Error loading activity: $err')),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: AppRoutes.lend),
    );
  }

  void _showLoanHistory(
    BuildContext context,
    List<AppTransaction> transactions,
  ) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: SizedBox(
            height: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All lending activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: transactions.isEmpty
                      ? const Center(child: Text('No lending activity yet.'))
                      : ListView.builder(
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _LoanTile(
                                transaction: transactions[index],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LoanTile extends StatelessWidget {
  const _LoanTile({required this.transaction});

  final AppTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedUser,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.amountText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: transaction.amountColor,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                transaction.isCredit ? 'Repaid' : 'Active',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
