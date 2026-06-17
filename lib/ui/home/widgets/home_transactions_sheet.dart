// lib/ui/home/widgets/home_transactions_sheet.dart
//
// Extracted from _showTransactions() on the original screen.

import 'package:flutter/material.dart';

import '../../../../data/models/wallet_transaction_model.dart';
import '../../../../shared/widgets/transaction_tile.dart';

class HomeTransactionsSheet extends StatelessWidget {
  const HomeTransactionsSheet({
    super.key,
    required this.title,
    required this.transactions,
  });

  final String title;
  final List<WalletTransactionModel> transactions;

  static void show(
    BuildContext context, {
    required String title,
    required List<WalletTransactionModel> transactions,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (_) => HomeTransactionsSheet(
        title: title,
        transactions: transactions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child:
                        Text('No transaction activity yet.'))
                : ListView.separated(
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) =>
                        TransactionTile(
                      transaction: transactions[index],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}