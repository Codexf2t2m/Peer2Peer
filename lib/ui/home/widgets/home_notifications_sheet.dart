
// Extracted from _showNotifications() on the original screen.

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../data/models/notification_model.dart';
import '../../../../shared/utils/formatters.dart';
import '../../../../ui/app_theme.dart';

class HomeNotificationsSheet extends StatelessWidget {
  const HomeNotificationsSheet({
    super.key,
    required this.notifications,
  });

  final List<NotificationModel> notifications;

  static void show(
    BuildContext context, {
    required List<NotificationModel> notifications,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (_) =>
          HomeNotificationsSheet(notifications: notifications),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: SizedBox(
        height: 360,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style:
                  Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(
                      child: Text('No notifications yet.'))
                  : ListView.separated(
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const HugeIcon(
                            icon: HugeIcons
                                .strokeRoundedNotification03,
                            color: AppTheme.iconColor,
                            size: 22,
                          ),
                          title: Text(item.title),
                          subtitle: Text(
                            '${item.message}\n'
                            '${formatRelativeNotificationTime(item.createdAt)}',
                          ),
                          isThreeLine: true,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}