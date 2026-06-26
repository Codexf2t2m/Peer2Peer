
// Extracted from _showOverview() on the original screen.

import 'package:flutter/material.dart';

import '../../../../data/models/home_overview_model.dart';
import '../../../../shared/utils/formatters.dart';
import 'overview_cards.dart';

class HomeOverviewSheet extends StatelessWidget {
  const HomeOverviewSheet({
    super.key,
    required this.overview,
  });

  final HomeOverviewModel overview;

  static void show(
    BuildContext context, {
    required HomeOverviewModel overview,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (_) => HomeOverviewSheet(overview: overview),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your overview',
            style:
                Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
          ),
          const SizedBox(height: 16),
          OverviewRow(
            label: 'Total lent',
            value: formatPula(overview.totalLent),
          ),
          const SizedBox(height: 10),
          OverviewRow(
            label: 'Interest earned',
            value: formatPula(overview.interestEarned),
          ),
          const SizedBox(height: 10),
          OverviewRow(
            label: 'Wallet balance',
            value: formatPula(overview.walletBalance),
          ),
          const SizedBox(height: 10),
          OverviewRow(
            label: 'Repayment rate',
            value: '${overview.repaymentRatePercent}%',
          ),
        ],
      ),
    );
  }
}