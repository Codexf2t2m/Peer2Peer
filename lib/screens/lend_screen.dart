import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_state.dart';
import '../ui/app_theme.dart';
import '../ui/widgets/app_card.dart';
import '../ui/widgets/section_header.dart';

class LendScreen extends StatelessWidget {
  const LendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DemoStore.instance,
      builder: (context, _) {
        final lendingActivity = DemoStore.instance.transactions
            .where(
              (transaction) =>
                  transaction.category == TransactionCategory.funding ||
                  transaction.category == TransactionCategory.repayment,
            )
            .toList();

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            title: Text('Lend', style: Theme.of(context).textTheme.titleMedium),
            actions: [
              IconButton(
                tooltip: 'New request',
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.request),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              children: [
                const SectionHeader(title: 'Your lending'),
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
                            DemoStore.instance.totalLentText,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ],
                      ),
                      FilledButton(
                        onPressed: () =>
                            Navigator.of(context).pushReplacementNamed(AppRoutes.community),
                        child: const Text('Lend now'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SectionHeader(
                  title: 'Active loans',
                  trailing: TextButton(
                    onPressed: () => _showLoanHistory(context, lendingActivity),
                    child: const Text('View all'),
                  ),
                ),
                const SizedBox(height: 12),
                if (lendingActivity.isEmpty)
                  const AppCard(child: Text('No lending activity yet.'))
                else
                  ...lendingActivity.take(4).map(
                    (transaction) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _LoanTile(transaction: transaction),
                    ),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: const _MainNav(selectedIndex: 2),
        );
      },
    );
  }

  void _showLoanHistory(BuildContext context, List<AppTransaction> transactions) {
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
                              child: _LoanTile(transaction: transactions[index]),
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
  const _LoanTile({
    required this.transaction,
  });

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
            child: const Icon(Icons.person_rounded, color: AppTheme.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(transaction.subtitle, style: Theme.of(context).textTheme.bodySmall),
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

class _MainNav extends StatelessWidget {
  const _MainNav({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: Colors.white,
      indicatorColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
      selectedIndex: selectedIndex,
      onDestinationSelected: (idx) {
        final route = switch (idx) {
          0 => AppRoutes.home,
          1 => AppRoutes.community,
          2 => AppRoutes.lend,
          _ => AppRoutes.wallet,
        };
        if (ModalRoute.of(context)?.settings.name == route) return;
        Navigator.of(context).pushReplacementNamed(route);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline_rounded),
          selectedIcon: Icon(Icons.people_rounded),
          label: 'Community',
        ),
        NavigationDestination(
          icon: Icon(Icons.handshake_outlined),
          selectedIcon: Icon(Icons.handshake_rounded),
          label: 'Lend',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          selectedIcon: Icon(Icons.account_balance_wallet_rounded),
          label: 'Wallet',
        ),
      ],
    );
  }
}
