
// Shown after a complaint is successfully submitted.
// Extracted from the screen's _buildSuccess() method.

import 'package:flutter/material.dart';

class ComplaintSuccessView extends StatelessWidget {
  const ComplaintSuccessView({
    super.key,
    required this.onDismiss,
  });

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF059669),
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Complaint submitted',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Our team will review your complaint within 5 business days '
              'and contact you via email with an update.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onDismiss,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back to app'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}