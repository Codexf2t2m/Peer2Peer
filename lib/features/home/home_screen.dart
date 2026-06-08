import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../app_routes.dart';
import '../../app_state.dart';
import '../../data/providers/data_providers.dart';
import '../../data/providers/session_provider.dart';
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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final walletBalanceAsync = ref.watch(walletBalanceProvider);
    final lendingOverviewAsync = ref.watch(lendingOverviewProvider);
    final transactionsAsync = ref.watch(transactionsProvider);
    final notificationsAsync = ref.watch(notificationsProvider);

    final displayName = session.currentEmail == null
        ? 'Mphoentle'
        : formatDisplayName(session.currentEmail);

    final recentTransactions = transactionsAsync.valueOrNull?.take(2).toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 24,
        title: HomeHeader(
          displayName: displayName,
          onSearch: () => _openSearch(context, ref),
          onNotifications: () => _showNotifications(context, ref),
        ),
        toolbarHeight: 70,
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(walletBalanceProvider);
            ref.invalidate(lendingOverviewProvider);
            ref.invalidate(transactionsProvider);
            ref.invalidate(notificationsProvider);
            // Wait for feeds to reload
            await ref.read(walletBalanceProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.request),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: HomeActionButton(
                      label: 'Ask Kutlo',
                      filled: false,
                      icon: HugeIcons.strokeRoundedAiMagic,
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.askKutlo),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SectionTitle(
                title: 'Your Overview',
                trailing: TextButton(
                  onPressed: () => _showOverview(context, ref),
                  child: const Text('View all'),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OverviewCard(
                      title: 'Total lent',
                      value: lendingOverviewAsync.maybeWhen(
                        data: (overview) => formatPula(overview['total_lent'] ?? 0),
                        orElse: () => 'P0',
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: OverviewCard(
                      title: 'Interest earned',
                      value: lendingOverviewAsync.maybeWhen(
                        data: (overview) => formatPula(overview['interest_earned'] ?? 0),
                        orElse: () => 'P0',
                      ),
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
                    transactions: transactionsAsync.valueOrNull ?? [],
                  ),
                  child: const Text('View all'),
                ),
              ),
              const SizedBox(height: 14),
              transactionsAsync.when(
                data: (_) {
                  if (recentTransactions.isEmpty) {
                    return const AppCard(
                      child: Text(
                        'No transactions yet. Fund someone or top up your wallet to get started.',
                      ),
                    );
                  }
                  return RecentTransactionsCard(transactions: recentTransactions);
                },
                error: (err, _) => AppCard(
                  child: Text('Error loading transactions: $err'),
                ),
                loading: () => const AppCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: AppRoutes.home),
    );
  }

  // ── Modals ──────────────────────────────────────────────────────────────────

  Future<void> _openSearch(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    var query = '';
    final membersAsync = ref.read(communityMembersProvider);
    final items = <_SearchItem>[
      _SearchItem(
        title: 'Community',
        subtitle: 'Browse borrowers',
        icon: HugeIcons.strokeRoundedUserGroup,
        onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.community),
      ),
      _SearchItem(
        title: 'Ask Kutlo AI',
        subtitle: 'Get advice on lending',
        icon: HugeIcons.strokeRoundedAiMagic,
        onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.askKutlo),
      ),
    ];

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredItems = items.where((item) {
              return item.title.toLowerCase().contains(query.toLowerCase()) ||
                  item.subtitle.toLowerCase().contains(query.toLowerCase());
            }).toList();

            final results = membersAsync.valueOrNull?.where((member) {
                  return member.name.toLowerCase().contains(query.toLowerCase()) ||
                      member.subtitle.toLowerCase().contains(query.toLowerCase());
                }).toList() ??
                [];

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, size: 20),
                      hintText: 'Search borrowers or features...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                controller.clear();
                                setModalState(() => query = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) => setModalState(() => query = val.trim()),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        if (filteredItems.isNotEmpty) ...[
                          const SectionTitle(title: 'Quick links'),
                          const SizedBox(height: 10),
                          ...filteredItems.map(
                            (item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFF7F8FA),
                                child: HugeIcon(
                                  icon: item.icon,
                                  color: AppTheme.iconColor,
                                  size: 20,
                                ),
                              ),
                              title: Text(item.title),
                              subtitle: Text(item.subtitle),
                              onTap: () {
                                Navigator.of(modalContext).pop();
                                item.onTap();
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (query.isNotEmpty) ...[
                          const SectionTitle(title: 'Matching borrowers'),
                          const SizedBox(height: 10),
                          if (results.isEmpty)
                            const Text('No borrowers found matching query.')
                          else
                            ...results.map(
                              (member) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(member.avatarUrl),
                                ),
                                title: Text(member.name),
                                subtitle: Text(member.subtitle),
                                trailing: Text(
                                  'Rep ${member.score}%',
                                  style: TextStyle(
                                    color: member.scoreColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(modalContext).pop();
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.communityFund,
                                    arguments: member.id,
                                  );
                                },
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    controller.dispose();
  }

  void _showNotifications(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.read(notificationsProvider);
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
                  child: notificationsAsync.when(
                    data: (notifications) {
                      if (notifications.isEmpty) {
                        return const Center(child: Text('No notifications yet.'));
                      }
                      return ListView.separated(
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
                      );
                    },
                    error: (err, _) => Center(child: Text('Error loading notifications: $err')),
                    loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOverview(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.read(walletBalanceProvider);
    final overviewAsync = ref.read(lendingOverviewProvider);

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
              OverviewRow(
                label: 'Total lent',
                value: overviewAsync.maybeWhen(
                  data: (data) => formatPula(data['total_lent'] ?? 0),
                  orElse: () => 'P0',
                ),
              ),
              const SizedBox(height: 10),
              OverviewRow(
                label: 'Interest earned',
                value: overviewAsync.maybeWhen(
                  data: (data) => formatPula(data['interest_earned'] ?? 0),
                  orElse: () => 'P0',
                ),
              ),
              const SizedBox(height: 10),
              OverviewRow(
                label: 'Wallet balance',
                value: balanceAsync.maybeWhen(
                  data: (balance) => formatPula(balance),
                  orElse: () => 'P0',
                ),
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
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: transactions.isEmpty
                    ? const Center(child: Text('No transaction activity yet.'))
                    : ListView.separated(
                        itemCount: transactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return TransactionTile(
                            transaction: transactions[index],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchItem {
  _SearchItem({
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
