import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../app_routes.dart';
import '../../app_state.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../shared/widgets/section_title.dart';
import '../../shared/widgets/transaction_tile.dart';
import '../../ui/app_theme.dart';
import 'widgets/home_action_button.dart';
import 'widgets/home_header.dart';
import 'widgets/loan_performance_card.dart';
import 'widgets/overview_cards.dart';
import 'widgets/recent_transactions_card.dart';
import 'widgets/stacked_card_carousel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([AppSession.instance, DemoStore.instance]),
      builder: (context, _) {
        final store = DemoStore.instance;
        final displayName = AppSession.instance.currentEmail == null
            ? 'Mphoentle'
            : formatDisplayName(AppSession.instance.currentEmail);
        final recentTransactions = store.transactions.take(2).toList();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 24,
            title: HomeHeader(
              displayName: displayName,
              onSearch: () => _openSearch(context),
              onNotifications: () => _showNotifications(context),
            ),
            toolbarHeight: 70,
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                const StackedCardCarousel(),
                const SizedBox(height: 30),
                const SectionTitle(title: 'Quick actions'),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: HomeActionButton(
                        label: 'Request',
                        filled: true,
                        icon: HugeIcons.strokeRoundedMoneyReceiveSquare,
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.request),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: HomeActionButton(
                        label: 'Ask Kutlo',
                        filled: false,
                        icon: HugeIcons.strokeRoundedAiMagic,
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.askKutlo),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SectionTitle(
                  title: 'Your Overview',
                  trailing: TextButton(
                    onPressed: () => _showOverview(context),
                    child: const Text('View all'),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OverviewCard(
                        title: 'Total lent',
                        value: store.totalLentText,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: OverviewCard(
                        title: 'Interest earned',
                        value: store.interestEarnedText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const LoanPerformanceCard(ratePercent: 91, monthlyDelta: 64),
                const SizedBox(height: 26),
                SectionTitle(
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
                const SizedBox(height: 14),
                if (recentTransactions.isEmpty)
                  const AppCard(
                    child: Text(
                      'No transactions yet. Fund someone or top up your wallet to get started.',
                    ),
                  )
                else
                  RecentTransactionsCard(transactions: recentTransactions),
                const SizedBox(height: 18),
              ],
            ),
          ),
          bottomNavigationBar: const BottomNavBar(currentRoute: AppRoutes.home),
        );
      },
    );
  }

  // ── Modals ──────────────────────────────────────────────────────────────────

  Future<void> _openSearch(BuildContext context) async {
    final controller = TextEditingController();
    var query = '';
    final store = DemoStore.instance;
    final items = <_SearchItem>[
      _SearchItem(
        title: 'Community',
        subtitle: 'Browse borrowers',
        icon: HugeIcons.strokeRoundedUserGroup,
        onTap: () => Navigator.of(context)
            .pushReplacementNamed(AppRoutes.community),
      ),
      _SearchItem(
        title: 'Wallet',
        subtitle: 'Top up or transfer',
        icon: HugeIcons.strokeRoundedWallet01,
        onTap: () =>
            Navigator.of(context).pushReplacementNamed(AppRoutes.wallet),
      ),
      _SearchItem(
        title: 'Lend',
        subtitle: 'Review your active loans',
        icon: HugeIcons.strokeRoundedPayment02,
        onTap: () =>
            Navigator.of(context).pushReplacementNamed(AppRoutes.lend),
      ),
      _SearchItem(
        title: 'Ask Kutlo',
        subtitle: 'Get lending guidance',
        icon: HugeIcons.strokeRoundedAiMagic,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.askKutlo),
      ),
      ...store.communityMembers.map(
        (member) => _SearchItem(
          title: member.name,
          subtitle: member.requestDescription,
          icon: HugeIcons.strokeRoundedUserGroup,
          onTap: () => Navigator.of(context)
              .pushNamed(AppRoutes.communityFund, arguments: member.id),
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
                      onChanged: (value) =>
                          setSheetState(() => query = value),
                      decoration: const InputDecoration(
                        hintText: 'Search screens, borrowers, or actions',
                        prefixIcon: HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          color: AppTheme.iconColor,
                          size: 22,
                        ),
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
                                  leading: HugeIcon(
                                    icon: item.icon,
                                    color: const Color(0xFF111827),
                                    size: 22,
                                  ),
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
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const HugeIcon(
                          icon: HugeIcons.strokeRoundedNotification03,
                          color: AppTheme.iconColor,
                          size: 22,
                        ),
                        title: Text(item.title),
                        subtitle: Text(
                          '${item.message}\n${formatRelativeNotificationTime(item.createdAt)}',
                        ),
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
              OverviewRow(label: 'Total lent', value: store.totalLentText),
              const SizedBox(height: 10),
              OverviewRow(
                label: 'Interest earned',
                value: store.interestEarnedText,
              ),
              const SizedBox(height: 10),
              OverviewRow(
                label: 'Wallet balance',
                value: store.walletBalanceText,
              ),
              const SizedBox(height: 10),
              const OverviewRow(label: 'Repayment rate', value: '91%'),
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
                  child: ListView.separated(
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return TransactionTile(
                        transaction: transactions[index],
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

// ── Search item model (private — only used inside this screen) ────────────────

class _SearchItem {
  const _SearchItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final List<List<dynamic>> icon;
  final VoidCallback onTap;
}
