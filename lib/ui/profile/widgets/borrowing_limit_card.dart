
// UC: View Borrowing Limit

import 'package:flutter/material.dart';

import '../../../data/models/credit_profile_model.dart';
import '../../../../shared/utils/formatters.dart';

class BorrowingLimitCard extends StatelessWidget {
  const BorrowingLimitCard({
    super.key,
    required this.creditProfile,
  });

  final CreditProfileModel creditProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Borrowing Limit',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E1E1E),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Next review',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    creditProfile.nextReviewLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0038FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatPula(creditProfile.approvedBorrowingLimit),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Income bracket: P1,000–P5,000/mo',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}