import 'package:flutter/material.dart';

class ReputationBadge extends StatelessWidget {
  const ReputationBadge({
    super.key,
    required this.score,
    required this.color,
  });

  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'Score',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E1E1E),
          ),
        ),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
