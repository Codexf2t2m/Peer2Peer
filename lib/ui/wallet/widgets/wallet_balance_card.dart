
// Displays the user's available balance and action buttons.
// Pure render widget — no provider access.

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../data/models/wallet_model.dart';
import '../../../../shared/utils/formatters.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../ui/app_theme.dart';

class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({
    super.key,
    required this.wallet,
    required this.onTopUp,
    required this.onTransfer,
    required this.onHistory,
  });

  final WalletModel wallet;
  final VoidCallback onTopUp;
  final VoidCallback onTransfer;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Balance card 
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
                    formatPula(wallet.availableBalance),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: onTopUp,
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

        const SizedBox(height: 12),

        // Action row 
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onTransfer,
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
                onPressed: onHistory,
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
    );
  }
}