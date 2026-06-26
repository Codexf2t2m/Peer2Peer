
// Displays a 4-segment colour-coded password strength indicator.
// Driven by the [passwordStrength] helper from the view model.

import 'package:flutter/material.dart';

import '../sign_up/view_models/sign_up_view_model.dart';

class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({
    super.key,
    required this.password,
  });

  final String password;

  @override
  Widget build(BuildContext context) {
    final score = passwordStrength(password);
    if (password.isEmpty) return const SizedBox.shrink();

    final (color, label) = switch (score) {
      0 || 1 => (const Color(0xFFEF4444), 'Weak'),
      2      => (const Color(0xFFF59E0B), 'Fair'),
      3      => (const Color(0xFF3B82F6), 'Good'),
      _      => (const Color(0xFF059669), 'Strong'),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: i < score ? color : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}