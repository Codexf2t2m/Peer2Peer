
// The result state shown after assessment completes.
// Extracted from _buildResultState(). Receives typed
// CreditAssessmentResultModel — no more raw fields off a result object.

import 'package:flutter/material.dart';

import '../../../../../data/models/credit_assessment_result_model.dart';
import 'score_ring_painter.dart';

class CreditResultView extends StatelessWidget {
  const CreditResultView({
    super.key,
    required this.result,
    required this.onContinue,
  });

  final CreditAssessmentResultModel result;
  final VoidCallback onContinue;

  Color _riskColor(String band) => switch (band.toLowerCase()) {
        'excellent' => const Color(0xFF059669),
        'good' => const Color(0xFF0D9488),
        'fair' => const Color(0xFFF59E0B),
        _ => const Color(0xFFEF4444),
      };

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(result.riskBand);

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success header 
            const Row(
              children: [
                Icon(Icons.check_circle,
                    color: Color(0xFF059669), size: 28),
                SizedBox(width: 10),
                Text(
                  'Assessment complete!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Score ring 
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CustomPaint(
                      painter: ScoreRingPainter(
                        progress: result.scorePercent,
                        color: color,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Text(
                              '${result.creditScore}',
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                            Text(
                              'out of 1000',
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(
                          alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      result.riskBand,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Borrowing limit card 
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0038FF),
                    const Color(0xFF0038FF)
                        .withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your borrowing limit',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'P ${result.borrowingLimit.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Available for community & direct loans',
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _InfoTile(
              icon: Icons.refresh_rounded,
              title: 'Monthly reassessment',
              subtitle:
                  'Your limit is reviewed every 30 days as your activity grows.',
            ),
            const SizedBox(height: 10),
            _InfoTile(
              icon: Icons.notifications_none_outlined,
              title: 'Account activated',
              subtitle:
                  'A notification has been sent confirming your account is live.',
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF0038FF),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Go to home',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: const Color(0xFF0038FF),
                size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}