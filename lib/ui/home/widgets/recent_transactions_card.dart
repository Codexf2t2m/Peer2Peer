
// Uses the same adapter pattern as HomeTransactionsSheet
// until TransactionTile accepts WalletTransactionModel directly.

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app_state.dart';
import '../../../../data/models/wallet_transaction_model.dart';
import '../../../../shared/widgets/transaction_tile.dart';

class RecentTransactionsCard extends StatelessWidget {
  const RecentTransactionsCard({
    super.key,
    required this.transactions,
  });

  final List<WalletTransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(transactions.length, (index) {
        return Column(
          children: [
            TransactionTile(
              transaction:
                  _toAppTransaction(transactions[index]),
            ),
            if (index != transactions.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 54),
                child: Divider(
                    height: 20,
                    color: Color(0xFFE3E6EA)),
              ),
          ],
        );
      }),
    );
  }

  static AppTransaction _toAppTransaction(
      WalletTransactionModel tx) {
    return AppTransaction(
      title: tx.title,
      subtitle: tx.subtitle,
      isCredit: tx.isCredit,
      icon: HugeIcons.strokeRoundedArrowDownLeft01,
      amount: tx.isCredit ? tx.grossAmount : -tx.grossAmount,
      category: tx.isCredit
          ? TransactionCategory.repayment
          : TransactionCategory.funding,
      createdAt: tx.createdAt,
    );
  }
}