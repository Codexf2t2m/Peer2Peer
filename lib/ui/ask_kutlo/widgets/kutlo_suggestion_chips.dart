
// Horizontally scrollable row of suggestion chips covering the five
// Kutlo use cases from the use case diagram.
// Shown only when there are no messages yet (empty conversation state).

import 'package:flutter/material.dart';

import '../view_models/kutlo_view_model.dart';

class KutloSuggestionChips extends StatelessWidget {
  const KutloSuggestionChips({
    super.key,
    required this.onSuggestionTap,
  });

  /// Called with the full prompt text when a chip is tapped.
  final void Function(String prompt) onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: kutloSuggestions.map((suggestion) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(suggestion.label),
              onPressed: () => onSuggestionTap(suggestion.prompt),
              labelStyle: const TextStyle(
                  fontSize: 12, color: Color(0xFF1E1E1E)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 4, vertical: 2),
              backgroundColor: const Color(0xFFF3F4F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}