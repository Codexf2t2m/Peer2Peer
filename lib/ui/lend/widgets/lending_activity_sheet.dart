
// Modal bottom sheet shown when the user taps "View all".
// Extracted from LendScreen._showLoanHistory so the screen stays thin.
// Receives the full activity list from the caller — no provider access.

import 'package:flutter/material.dart';

import '../../../data/models/lending_activity_model.dart';
import 'lending_activity_tile.dart';

class LendingActivitySheet extends StatelessWidget {
  const LendingActivitySheet({
    super.key,
    required this.activities,
  });

  final List<LendingActivityModel> activities;

  /// Convenience method — mirrors the original _showLoanHistory pattern.
  static void show(
    BuildContext context, {
    required List<LendingActivityModel> activities,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => LendingActivitySheet(activities: activities),
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
              'All lending activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: activities.isEmpty
                  ? const Center(
                      child: Text('No lending activity yet.'),
                    )
                  : ListView.separated(
                      itemCount: activities.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) =>
                          LendingActivityTile(
                        activity: activities[index],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}