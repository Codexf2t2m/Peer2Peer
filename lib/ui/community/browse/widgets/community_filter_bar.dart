
// UC: Filter Community Feed
//
// Horizontally scrollable row of filter chips.
// Pure render widget — receives selected filter and callback.

import 'package:flutter/material.dart';

import '../view_models/community_browse_view_model.dart';

class CommunityFilterBar extends StatelessWidget {
  const CommunityFilterBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final CommunityFilter activeFilter;
  final ValueChanged<CommunityFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: CommunityFilter.values.map((filter) {
          final isSelected = activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onFilterChanged(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0038FF)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: Colors.grey.shade300,
                            width: 0.8,
                          ),
                  ),
                  child: Text(
                    filter.label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF2C2C2C),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}