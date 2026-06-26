import '../../app_state.dart';

export '../../app_state.dart' show formatPula;

String formatDisplayName(String? email) => displayNameFromEmail(email);

String formatRelativeNotificationTime(DateTime value) =>
    formatNotificationTime(value);
