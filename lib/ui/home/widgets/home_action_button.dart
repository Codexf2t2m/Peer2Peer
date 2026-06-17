// lib/ui/home/widgets/home_action_button.dart
//
// Fixed: icon was typed as List<List<dynamic>> — now IconData.

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../ui/app_theme.dart';

class HomeActionButton extends StatelessWidget {
  const HomeActionButton({
    super.key,
    required this.label,
    required this.filled,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final IconData icon; // was List<List<dynamic>> — fixed
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground =
        filled ? Colors.white : const Color(0xFF111111);
    final background =
        filled ? AppTheme.primaryBlue : Colors.white;
    final borderColor =
        filled ? Colors.transparent : AppTheme.buttonStroke;

    return SizedBox(
      height: 46,
      child: filled
          ? FilledButton.icon(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: background,
                foregroundColor: foreground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23),
                ),
              ),
              icon: HugeIcon(
                  icon: icon, color: foreground, size: 18),
              label: Text(label),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: background,
                foregroundColor: foreground,
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23),
                ),
              ),
              icon: HugeIcon(
                  icon: icon, color: foreground, size: 18),
              label: Text(label),
            ),
    );
  }
}