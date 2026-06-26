import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_model.dart';

class NotificationRepository {
  final SupabaseClient _db;

  NotificationRepository(this._db);

  String? get _uid => _db.auth.currentUser?.id;

  /// Fetches all notifications for the current user, newest first.
  Future<List<NotificationModel>> fetchMyNotifications({
    int limit = 30,
  }) async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final List<Map<String, dynamic>> data = await _db
          .from('notifications')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(limit);

      return data.map((row) => NotificationModel.fromJson(row)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to load notifications: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred while loading notifications.');
    }
  }

  /// Returns the number of unread notifications.
  Future<int> fetchUnreadCount() async {
    final uid = _uid;
    if (uid == null) return 0;

    try {
      final List<Map<String, dynamic>> data = await _db
          .from('notifications')
          .select('id')
          .eq('user_id', uid)
          .eq('is_read', false);

      return data.length;
    } on PostgrestException catch (e) {
      throw Exception('Failed to get notifications count: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred.');
    }
  }

  /// Marks a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    try {
      await _db
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } on PostgrestException catch (e) {
      throw Exception('Failed to update notification: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred.');
    }
  }

  /// Marks all unread notifications for the current user as read.
  Future<void> markAllAsRead() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      await _db
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', uid)
          .eq('is_read', false);
    } on PostgrestException catch (e) {
      throw Exception('Failed to update notifications: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred.');
    }
  }
}
