import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_state.dart';
import '../ui/app_theme.dart';
import '../ui/widgets/app_card.dart';
import '../ui/widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([AppSession.instance, DemoStore.instance]),
      builder: (context, _) {
        final store = DemoStore.instance;
        final displayName = displayNameFromEmail(AppSession.instance.currentEmail);
        final recentTransactions = store.transactions.take(2).toList();

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            title: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3D6),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('🐻', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 10),
                Text(
                  'Hi, $displayName',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Search',
                onPressed: () => _openSearch(context),
                icon: const Icon(Icons.search_rounded),
              ),
              IconButton(
                tooltip: 'Notifications',
                onPressed: () => _showNotifications(context),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              IconButton(
                tooltip: 'Profile',
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
                icon: const Icon(Icons.person_outline_rounded),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              children: [
                const _CardCarousel(
                  cards: [
                    _CreditCardMock(),
                  ],
                ),
                const SizedBox(height: 18),
                const SectionHeader(title: 'Quick actions'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.request),
                        icon: const Icon(Icons.sync_alt_rounded, size: 18),
                        label: const Text('Request'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.askKutlo),
                        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                        label: const Text('Ask Kutlo'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SectionHeader(
                  title: 'Your Overview',
                  trailing: TextButton(
                    onPressed: () => _showOverview(context),
                    child: const Text('View all'),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total lent',
                        value: store.totalLentText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Interest earned',
                        value: store.interestEarnedText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _LoanPerformanceCard(
                  ratePercent: 91,
                  monthlyDelta: 64,
                ),
                const SizedBox(height: 22),
                SectionHeader(
                  title: 'Recent Transactions',
                  trailing: TextButton(
                    onPressed: () => _showTransactions(
                      context,
                      title: 'All activity',
                      transactions: store.transactions,
                    ),
                    child: const Text('View all'),
                  ),
                ),
                const SizedBox(height: 10),
                if (recentTransactions.isEmpty)
                  const AppCard(
                    child: Text('No transactions yet. Fund someone or top up your wallet to get started.'),
                  )
                else
                  ...recentTransactions.map(
                    (transaction) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TransactionTile(
                        title: transaction.title,
                        subtitle: transaction.subtitle,
                        amountText: transaction.amountText,
                        amountColor: transaction.amountColor,
                        icon: transaction.icon,
                      ),
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            backgroundColor: Colors.white,
            indicatorColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
            selectedIndex: 0,
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
          ),
        );
      },
    );
  }

  Future<void> _openSearch(BuildContext context) async {
    final controller = TextEditingController();
    var query = '';
    final store = DemoStore.instance;
    final items = <_HomeSearchItem>[
      _HomeSearchItem(
        title: 'Community',
        subtitle: 'Browse borrowers',
        icon: Icons.people_rounded,
        onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.community),
      ),
      _HomeSearchItem(
        title: 'Wallet',
        subtitle: 'Top up or transfer',
        icon: Icons.account_balance_wallet_rounded,
        onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.wallet),
      ),
      _HomeSearchItem(
        title: 'Lend',
        subtitle: 'Review your active loans',
        icon: Icons.handshake_rounded,
        onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.lend),
      ),
      _HomeSearchItem(
        title: 'Ask Kutlo',
        subtitle: 'Get lending guidance',
        icon: Icons.auto_awesome_rounded,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.askKutlo),
      ),
      ...store.communityMembers.map(
        (member) => _HomeSearchItem(
          title: member.name,
          subtitle: member.requestDescription,
          icon: Icons.person_rounded,
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.communityFund,
            arguments: member.id,
          ),
        ),
      ),
    ];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filteredItems = items.where((item) {
              if (query.trim().isEmpty) return true;
              final text = '${item.title} ${item.subtitle}'.toLowerCase();
              return text.contains(query.toLowerCase());
            }).toList();

            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: 420,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      onChanged: (value) => setSheetState(() => query = value),
                      decoration: const InputDecoration(
                        hintText: 'Search screens, borrowers, or actions',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filteredItems.isEmpty
                          ? const Center(child: Text('No matching results.'))
                          : ListView.builder(
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return ListTile(
                                  leading: Icon(item.icon),
                                  title: Text(item.title),
                                  subtitle: Text(item.subtitle),
                                  onTap: () {
                                    Navigator.of(sheetContext).pop();
                                    item.onTap();
                                  },
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
      },
    );

    controller.dispose();
  }

  void _showNotifications(BuildContext context) {
    final notifications = DemoStore.instance.notifications;
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: SizedBox(
            height: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.notifications_active_outlined),
                        title: Text(item.title),
                        subtitle: Text('${item.message}\n${formatNotificationTime(item.createdAt)}'),
                        isThreeLine: true,
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

  void _showOverview(BuildContext context) {
    final store = DemoStore.instance;
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 16),
              _OverviewRow(label: 'Total lent', value: store.totalLentText),
              const SizedBox(height: 10),
              _OverviewRow(label: 'Interest earned', value: store.interestEarnedText),
              const SizedBox(height: 10),
              _OverviewRow(label: 'Wallet balance', value: store.walletBalanceText),
              const SizedBox(height: 10),
              const _OverviewRow(label: 'Repayment rate', value: '91%'),
            ],
          ),
        );
      },
    );
  }

  void _showTransactions(
    BuildContext context, {
    required String title,
    required List<AppTransaction> transactions,
  }) {
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
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TransactionTile(
                          title: transaction.title,
                          subtitle: transaction.subtitle,
                          amountText: transaction.amountText,
                          amountColor: transaction.amountColor,
                          icon: transaction.icon,
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

class _HomeSearchItem {
  const _HomeSearchItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _CardCarousel extends StatelessWidget {
  const _CardCarousel({required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 185,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 18,
                right: 18,
                top: 18,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: const Color(0xFF39B9C5),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 18,
                child: PageView(
                  children: cards,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _Dot(isActive: true),
            SizedBox(width: 6),
            _Dot(isActive: false),
            SizedBox(width: 6),
            _Dot(isActive: false),
          ],
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: isActive ? 18 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF111827) : const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _CreditCardMock extends StatelessWidget {
  const _CreditCardMock();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B0F17),
            Color(0xFF2A2F3A),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: const DefaultTextStyle(
        style: TextStyle(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FNB', style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text('Credit', style: TextStyle(color: Color(0xFFBFC4CE))),
                  ],
                ),
                Text(
                  'VISA',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ],
            ),
            Spacer(),
            Text('Balance', style: TextStyle(color: Color(0xFFBFC4CE))),
            SizedBox(height: 4),
            Text(
              'P5 348.00',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 10),
            Text(
              '****  -  ****  -  ****  -  **68',
              style: TextStyle(
                letterSpacing: 1.2,
                color: Color(0xFFDFE3EA),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(child: _StatCardBody(title: title, value: value));
  }
}

class _StatCardBody extends StatelessWidget {
  const _StatCardBody({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 18),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _LoanPerformanceCard extends StatelessWidget {
  const _LoanPerformanceCard({
    required this.ratePercent,
    required this.monthlyDelta,
  });

  final int ratePercent;
  final int monthlyDelta;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loan Performance',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.trending_up_rounded,
                    size: 18,
                    color: Color(0xFF22C55E),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+P$monthlyDelta this month',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$ratePercent%',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Repayment rate',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amountText,
    required this.amountColor,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String amountText;
  final Color amountColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF111827)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            amountText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: amountColor,
                ),
          ),
        ],
      ),
    );
  }
}
