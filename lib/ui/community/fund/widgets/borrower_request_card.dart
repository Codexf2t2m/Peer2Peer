
// Displays the borrower's current loan request — progress ring + stats.
// Extracted from the screen's inline Column. Pure render widget.

import 'package:flutter/material.dart';

import '../../../../data/models/borrower_profile_model.dart';

class BorrowerRequestCard extends StatelessWidget {
  const BorrowerRequestCard({
    super.key,
    required this.profile,
  });

  final BorrowerProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Progress ring 
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: profile.progress,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFF0F2F5),
                  color: const Color(0xFF0038FF),
                ),
                Text(
                  profile.progressText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // ── Stats ──────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                _StatRow(
                  label: 'Target amount',
                  value: _formatPula(profile.amountRequested),
                ),
                const SizedBox(height: 10),
                _StatRow(
                  label: 'Interest rate',
                  value:
                      '${profile.interestRate.toStringAsFixed(0)}%',
                ),
                const SizedBox(height: 10),
                _StatRow(
                  label: 'Due in',
                  value: profile.dueIn,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatPula(double amount) =>
      'P ${amount.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+\.)'),
            (m) => '${m[1]},',
          )}';
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade900,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E1E1E),
          ),
        ),
      ],
    );
  }
}