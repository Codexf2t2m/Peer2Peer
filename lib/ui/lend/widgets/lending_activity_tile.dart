import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../data/models/lending_activity_model.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../ui/app_theme.dart';
import '../view_models/lend_view_model.dart';

class LendingActivityTile extends StatelessWidget {
  const LendingActivityTile({
    super.key,
    required this.activity,
  });

  final LendingActivityModel activity;

  @override
  Widget build(BuildContext context) {
    final iconColor = activityIconColor(activity);
    final amountColor = activityAmountColor(activity);
    final amountText = activityAmountText(activity);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Avatar circle 
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: activity.isRepayment
                  ? HugeIcons.strokeRoundedMoneyReceive02
                  : HugeIcons.strokeRoundedMoneySend02,
              color: iconColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Title + subtitle 
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.tileTitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  activity.displayBorrowerName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Amount + status 
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: amountColor,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                activity.typeLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}