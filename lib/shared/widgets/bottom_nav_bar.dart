import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../app_routes.dart';
import '../../ui/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.currentRoute});

  final String currentRoute;

  static const _routes = [
    AppRoutes.home,
    AppRoutes.community,
    AppRoutes.lend,
    AppRoutes.wallet,
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _routes.indexOf(currentRoute);

    return NavigationBar(
      backgroundColor: Colors.white,
      indicatorColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      onDestinationSelected: (idx) {
        final route = _routes[idx];
        if (ModalRoute.of(context)?.settings.name == route) return;
        Navigator.of(context).pushReplacementNamed(route);
      },
      destinations: const [
        NavigationDestination(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedHome01,
            color: AppTheme.iconColor,
            size: 24,
          ),
          selectedIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedHome01,
            color: AppTheme.iconColor,
            size: 24,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedUser,
            color: AppTheme.iconColor,
            size: 24,
          ),
          selectedIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedUser02,
            color: AppTheme.iconColor,
            size: 24,
          ),
          label: 'Community',
        ),
        NavigationDestination(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedUserGroup,
            color: AppTheme.iconColor,
            size: 24,
          ),
          selectedIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedUserGroup02,
            color: AppTheme.iconColor,
            size: 24,
          ),
          label: 'Lend',
        ),
        NavigationDestination(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedWallet01,
            color: AppTheme.iconColor,
            size: 24,
          ),
          selectedIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedWallet05,
            color: AppTheme.iconColor,
            size: 24,
          ),
          label: 'Wallet',
        ),
      ],
    );
  }
}
