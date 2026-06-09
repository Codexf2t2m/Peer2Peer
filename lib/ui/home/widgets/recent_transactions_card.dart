import 'package:flutter/material.dart';

import '../../../app_state.dart';
import '../../../shared/widgets/transaction_tile.dart';

class RecentTransactionsCard extends StatelessWidget {
  const RecentTransactionsCard({super.key, required this.transactions});

  final List<AppTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(transactions.length, (index) {
        final transaction = transactions[index];
        return Column(
          children: [
            TransactionTile(transaction: transaction),
            if (index != transactions.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 54),
                child: Divider(height: 20, color: Color(0xFFE3E6EA)),
              ),
          ],
        );
      }),
    );
  }
}
