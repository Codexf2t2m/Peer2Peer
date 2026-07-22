
// The animated 3-column grid for selecting the complaint type.
// Extracted from the screen — pure render widget, no provider access.

import 'package:flutter/material.dart';

import '../../../data/models/complaint_model.dart';
import '../view_models/complaint_view_model.dart';

class ComplaintTypeGrid extends StatelessWidget {
  const ComplaintTypeGrid({
    super.key,
    required this.selectedType,
    required this.onChanged,
    required this.enabled,
  });

  final ComplaintType selectedType;
  final ValueChanged<ComplaintType> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.35,
      children: complaintTypeOptions.map((option) {
        final selected = selectedType == option.type;
        return GestureDetector(
          onTap: enabled ? () => onChanged(option.type) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFEFF6FF)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? const Color(0xFF0038FF)
                    : const Color(0xFFE5E7EB),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  option.icon,
                  size: 22,
                  color: selected
                      ? const Color(0xFF0038FF)
                      : const Color(0xFF9CA3AF),
                ),
                const SizedBox(height: 4),
                Text(
                  option.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: selected
                        ? const Color(0xFF0038FF)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}