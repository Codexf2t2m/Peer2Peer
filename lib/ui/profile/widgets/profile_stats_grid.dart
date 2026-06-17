
import 'package:flutter/material.dart';

import '../../../data/models/profile_stats_model.dart';

class ProfileStatsGrid extends StatelessWidget {
  const ProfileStatsGrid({super.key, required this.stats});

  final ProfileStatsModel stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _StatCard(
            value: '${stats.totalRequested}',
            label: 'Loans requested'),
        _StatCard(
            value: '${stats.fullyRepaid}',
            label: 'Fully repaid'),
        _StatCard(
            value: '${stats.peopleFunded}',
            label: 'People funded'),
        _StatCard(
            value: '${stats.latePayments}',
            label: 'Late payments'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}