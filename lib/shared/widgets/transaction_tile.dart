import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../app_state.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction});

  final AppTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: HugeIcon(
              icon: transaction.icon,
              color: const Color(0xFF101318),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                transaction.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: const Color(0xFF7E838B),
                ),
              ),
            ],
          ),
        ),
        Text(
          transaction.amountText,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: transaction.amountColor,
          ),
        ),
      ],
    );
  }
}
