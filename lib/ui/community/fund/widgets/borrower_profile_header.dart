
import 'package:flutter/material.dart';

import '../../../../data/models/borrower_profile_model.dart';

class BorrowerProfileHeader extends StatelessWidget {
  const BorrowerProfileHeader({
    super.key,
    required this.profile,
    required this.walletBalance,
  });

  final BorrowerProfileModel profile;
  final double walletBalance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar 
        CircleAvatar(
          radius: 44,
          backgroundImage: NetworkImage(profile.avatarUrl),
          backgroundColor: Colors.grey.shade200,
        ),
        const SizedBox(height: 16),

        // Name 
        Text(
          profile.borrowerName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.subtitle,
          style: TextStyle(
              fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),

        // Rep score pill 
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.grey.shade300, width: 0.8),
          ),
          child: Text(
            'Rep Score ${profile.reputationScore} · ${profile.scoreLabel}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E1E1E),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Wallet balance 
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your wallet balance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              Text(
                _formatPula(walletBalance),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0038FF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatPula(double amount) =>
      'P ${amount.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+\.)'),
            (m) => '${m[1]},',
          )}';
}