import '../../app_state.dart';

String formatDisplayName(String? email) => displayNameFromEmail(email);

String formatRelativeNotificationTime(DateTime value) =>
    formatNotificationTime(value);
