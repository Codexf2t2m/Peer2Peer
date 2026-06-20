
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.displayName,
    required this.onSearch,
    required this.onNotifications,
    this.hasUnreadNotifications = false,
  });

  final String displayName;
  final VoidCallback onSearch;
  final VoidCallback onNotifications;
  final bool hasUnreadNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFFFFE6B8),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text('🧸',
              style: TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            displayName.isEmpty
                ? 'Hi there'
                : 'Hi, $displayName',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.1,
                ),
          ),
        ),
        HeaderIconButton(
          // HugeIcons values are List<List<dynamic>>
          icon: HugeIcons.strokeRoundedSearch01,
          onTap: onSearch,
        ),
        const SizedBox(width: 10),
        HeaderIconButton(
          icon: HugeIcons.strokeRoundedNotification03,
          onTap: onNotifications,
          showDot: hasUnreadNotifications,
        ),
      ],
    );
  }
}

class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  // HugeIcons values are List<List<dynamic>>, not IconData
  final List<List<dynamic>> icon;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 28,
        height: 28,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: HugeIcon(
                icon: icon,
                color: const Color(0xFF101318),
                size: 22,
              ),
            ),
            if (showDot)
              const Positioned(
                top: 3,
                right: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(width: 6, height: 6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}