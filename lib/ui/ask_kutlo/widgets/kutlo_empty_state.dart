
// Shown in the chat area when no messages exist yet.
// Greets the user by name using the loaded context.

import 'package:flutter/material.dart';

class KutloEmptyState extends StatelessWidget {
  const KutloEmptyState({
    super.key,
    required this.userName,
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
    final firstName = userName.split(' ').first;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF0038FF).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Color(0xFF0038FF),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hi $firstName, I\'m Kutlo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your personal financial AI. Ask me about your credit, '
              'lending limits, loan requests, or any money question.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}