
import 'package:flutter/material.dart';

import '../../../data/models/wallet_transaction_model.dart';
import 'wallet_transaction_tile.dart';

class WalletHistorySheet extends StatelessWidget {
  const WalletHistorySheet({
    super.key,
    required this.transactions,
  });

  final List<WalletTransactionModel> transactions;

  static void show(
    BuildContext context, {
    required List<WalletTransactionModel> transactions,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) =>
          WalletHistorySheet(transactions: transactions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: SizedBox(
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wallet history',
              style:
                  Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: transactions.isEmpty
                  ? const Center(
                      child: Text('No transactions yet.'),
                    )
                  : ListView.separated(
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) =>
                          WalletTransactionTile(
                        transaction: transactions[index],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}