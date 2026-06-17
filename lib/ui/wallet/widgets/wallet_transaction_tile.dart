import 'package:flutter/material.dart';

import '../../../data/models/wallet_transaction_model.dart';
import '../../../../shared/utils/formatters.dart';
import '../../../../shared/widgets/app_card.dart';

class WalletTransactionTile extends StatelessWidget {
  const WalletTransactionTile({
    super.key,
    required this.transaction,
  });

  final WalletTransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final amountColor = transaction.isCredit
        ? const Color(0xFF059669)
        : const Color(0xFF1E1E1E);
    final amountPrefix = transaction.isCredit ? '+' : '';

    return AppCard(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Icon 
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                transaction.icon, // Changed to native Icon to accept IconData safely
                color: const Color(0xFF111827),
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Title + subtitle 
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Amount 
          Text(
            '$amountPrefix${formatPula(transaction.grossAmount)}',
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