import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.color = const Color(0xFF1E1E1E)});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () => Navigator.of(context).maybePop(),
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedArrowLeft02,
        color: color,
        size: 24,
      ),
    );
  }
}
