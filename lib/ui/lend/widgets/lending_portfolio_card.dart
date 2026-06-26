// Displays the lender's total outstanding balance and a "Lend now" CTA.
// Pure render widget — receives typed data, no provider access.

import 'package:flutter/material.dart';

import '../../../data/models/lending_overview_model.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../app_routes.dart';
import '../../../../shared/utils/formatters.dart';

class LendingPortfolioCard extends StatelessWidget {
  const LendingPortfolioCard({
    super.key,
    required this.overview,
  });

  final LendingOverviewModel overview;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: balance stack 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Outstanding',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                formatPula(overview.totalLent),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              if (overview.hasActiveLoans) ...[
                const SizedBox(height: 4),
                Text(
                  '${overview.activeContributionsCount} active loan${overview.activeContributionsCount == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),

          // Right: CTA 
          FilledButton(
            onPressed: () => Navigator.of(context)
                .pushReplacementNamed(AppRoutes.community),
            child: const Text('Lend now'),
          ),
        ],
      ),
    );
  }
}