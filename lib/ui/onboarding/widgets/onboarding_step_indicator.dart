
// Shared step progress indicator used by all four onboarding screens.
// Extracted unchanged — pure render widget.

import 'package:flutter/material.dart';

class OnboardingStepIndicator extends StatelessWidget {
  const OnboardingStepIndicator({
    super.key,
    required this.currentStep,
  });

  final int currentStep;

  static const _labels = ['Email', 'Bank', 'ID', 'Credit'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: i ~/ 2 < currentStep
                  ? const Color(0xFF0038FF)
                  : const Color(0xFFE5E7EB),
            ),
          );
        }
        final step = i ~/ 2;
        final done = step < currentStep;
        final active = step == currentStep;

        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done || active
                    ? const Color(0xFF0038FF)
                    : const Color(0xFFE5E7EB),
              ),
              child: Icon(
                done ? Icons.check : Icons.circle,
                size: done ? 16 : 8,
                color: done || active
                    ? Colors.white
                    : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _labels[step],
              style: TextStyle(
                fontSize: 10,
                fontWeight: active
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: active
                    ? const Color(0xFF0038FF)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        );
      }),
    );
  }
}