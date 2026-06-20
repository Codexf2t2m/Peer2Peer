
// TransactionTile still expects AppTransaction.
// We pass WalletTransactionModel.toAppTransaction() as an adapter
// until TransactionTile is updated to accept WalletTransactionModel.


import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app_state.dart';
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
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Text(
                        'No transaction activity yet.'))
                : ListView.separated(
                    itemCount: transactions.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) =>
                        TransactionTile(
                      transaction: _toAppTransaction(
                          transactions[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Adapter: converts WalletTransactionModel to AppTransaction
  /// until TransactionTile is updated to accept the new type.
  static AppTransaction _toAppTransaction(
      WalletTransactionModel tx) {
    return AppTransaction(
      title: tx.title,
      isCredit: tx.isCredit,
      icon: HugeIcons.strokeRoundedArrowDownLeft01,
      subtitle: tx.subtitle,
      amount: tx.isCredit ? tx.grossAmount : -tx.grossAmount,
      category: tx.isCredit
          ? TransactionCategory.repayment
          : TransactionCategory.funding,
      createdAt: tx.createdAt,
    );
  }
}