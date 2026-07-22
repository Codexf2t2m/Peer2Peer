
// Segmented toggle for selecting request type:
//   • Community — visible to all lenders on the community feed
//   • Direct    — targeted at a specific lender
//
// Covers UC: Request Community Loan + Request Direct Loan

import 'package:flutter/material.dart';

class RequestTypeToggle extends StatelessWidget {
  const RequestTypeToggle({
    super.key,
    required this.selectedType,
    required this.onChanged,
    required this.enabled,
  });

  /// 'community' | 'direct'
  final String selectedType;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Request type',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 10),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'community',
              label: Text('Community'),
              icon: Icon(Icons.people_outline, size: 16),
            ),
            ButtonSegment(
              value: 'direct',
              label: Text('Direct'),
              icon: Icon(Icons.person_outline, size: 16),
            ),
          ],
          selected: {selectedType},
          onSelectionChanged: enabled
              ? (selection) => onChanged(selection.first)
              : null,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          selectedType == 'community'
              ? 'Visible to all lenders on the community feed.'
              : 'Sent directly to a specific lender.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF9CA3AF),
              ),
        ),
      ],
    );
  }
}