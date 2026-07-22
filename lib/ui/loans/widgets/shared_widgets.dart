// lib/ui/loans/widgets/shared_widgets.dart
//
// Atomic UI components shared across the loans feature.
// None of these import any view model or provider — they are pure render
// widgets driven entirely by the values passed to their constructors.

import 'package:flutter/material.dart';

// ── SectionHeader ─────────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.badge,
  });

  final String title;
  final IconData icon;

  /// Optional badge text (e.g. overdue count) shown in a red pill.
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF374151)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1E1E),
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── StatusBadge ───────────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── EmptyCard ─────────────────────────────────────────────────────────────────

class EmptyCard extends StatelessWidget {
  const EmptyCard({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9CA3AF), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: Color(0xFF6B7280), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ── ErrorCard ─────────────────────────────────────────────────────────────────

class ErrorCard extends StatelessWidget {
  const ErrorCard({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;

  /// When provided a "Try again" button is shown.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message.replaceFirst('Exception: ', ''),
              style: const TextStyle(
                  color: Color(0xFFEF4444), fontSize: 13),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── LoadingSection 

class LoadingSection extends StatelessWidget {
  const LoadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}