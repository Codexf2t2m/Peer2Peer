
// UC: View Credit Score

import 'package:flutter/material.dart';

import '../../../data/models/credit_profile_model.dart';

class CreditScoreCard extends StatelessWidget {
  const CreditScoreCard({
    super.key,
    required this.creditProfile,
  });

  final CreditProfileModel creditProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 84,
              height: 84,
              child: CircularProgressIndicator(
                value: creditProfile.scorePercent,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFF0038FF),
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              creditProfile.scorePercentLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '${creditProfile.riskBand} — Top 15% of PulaPay users',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}