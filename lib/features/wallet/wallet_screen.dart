import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../app_routes.dart';
import '../../../app_state.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../ui/app_theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DemoStore.instance,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            title: Text(
              'Wallet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            actions: [
              IconButton(
                tooltip: 'Profile',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.profile),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedUser,
                  color: AppTheme.iconColor,
                  size: 24,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              children: [
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available balance',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DemoStore.instance.walletBalanceText,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      FilledButton.icon(
                        onPressed: () => _showTopUpDialog(context),
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedWalletAdd02,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text('Top up'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const SectionTitle(title: 'Cards'),
                const SizedBox(height: 12),
                const _WalletCardMock(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showTransferDialog(context),
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowLeftRight,
                          color: AppTheme.iconColor,
                          size: 18,
                        ),
                        label: const Text('Transfer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showHistory(context),
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedReceiptText,
                          color: AppTheme.iconColor,
                          size: 18,
                        ),
                        label: const Text('History'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar:
              const BottomNavBar(currentRoute: AppRoutes.wallet),
        );
      },
    );
  }

  Future<void> _showTopUpDialog(BuildContext rootContext) async {
    final controller = TextEditingController(text: '200');
    var errorText = '';

    await showDialog<void>(
      context: rootContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Top up wallet'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: 'P',
                    ),
                  ),
                  if (errorText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorText,
                      style: const TextStyle(color: Color(0xFFDC2626)),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final amount = double.tryParse(controller.text.trim()) ?? 0;
                    final result = DemoStore.instance.topUpWallet(amount);
                    if (!result.success) {
                      setDialogState(() => errorText = result.message);
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(
                      rootContext,
                    ).showSnackBar(SnackBar(content: Text(result.message)));
                  },
                  child: const Text('Add funds'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  Future<void> _showTransferDialog(BuildContext rootContext) async {
    final recipientController = TextEditingController();
    final amountController = TextEditingController(text: '100');
    var errorText = '';

    await showDialog<void>(
      context: rootContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Transfer from wallet'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: recipientController,
                    decoration: const InputDecoration(
                      labelText: 'Recipient',
                      hintText: 'Name or mobile number',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: 'P',
                    ),
                  ),
                  if (errorText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorText,
                      style: const TextStyle(color: Color(0xFFDC2626)),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final amount =
                        double.tryParse(amountController.text.trim()) ?? 0;
                    final result = DemoStore.instance.transferFromWallet(
                      amount: amount,
                      recipient: recipientController.text,
                    );
                    if (!result.success) {
                      setDialogState(() => errorText = result.message);
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(
                      rootContext,
                    ).showSnackBar(SnackBar(content: Text(result.message)));
                  },
                  child: const Text('Transfer'),
                ),
              ],
            );
          },
        );
      },
    );

    recipientController.dispose();
    amountController.dispose();
  }

  void _showHistory(BuildContext context) {
    final transactions = DemoStore.instance.transactions;
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
                  'Wallet history',
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
                        child: _HistoryTile(transaction: transaction),
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

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.transaction});

  final AppTransaction transaction;

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
            child: Center(
              child: HugeIcon(
                icon: transaction.icon,
                color: const Color(0xFF111827),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            transaction.amountText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: transaction.amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletCardMock extends StatelessWidget {
  const _WalletCardMock();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B0F17), Color(0xFF2A2F3A)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FNB',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text('Credit', style: TextStyle(color: Color(0xFFBFC4CE))),
                ],
              ),
              Text(
                'VISA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Spacer(),
          Text(
            '****  -  ****  -  ****  -  **68',
            style: TextStyle(color: Color(0xFFDFE3EA)),
          ),
        ],
      ),
    );
  }
}
