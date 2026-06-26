
// Single data boundary for the Profile feature.
//
// Reads sequentially (Future.wait omitted — mixed Supabase return types
// prevent the type parameter from being inferred):
//   PROFILES         → name, email, reputation_score, location, created_at
//   CREDIT_PROFILES  → credit_score, risk_band, approved_borrowing_limit
//   USER_BADGES      → earned badges joined with BADGES
//   get_profile_stats RPC → aggregated loan/funding counts

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/badge_model.dart';
import '../models/credit_profile_model.dart';
import '../models/profile_stats_model.dart';
import '../models/user_profile_model.dart';

class ProfileRepository {
  ProfileRepository(this._db);

  final SupabaseClient _db;

  String? get _uid => _db.auth.currentUser?.id;

  Future<UserProfileModel> fetchProfile() async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in.');

    try {
      // Sequential awaits avoid Future.wait type-inference issues
      // with mixed Supabase builder return types.

      final profileData = await _db
          .from('profiles')
          .select(
              'id, full_name, email, reputation_score, location, created_at')
          .eq('id', uid)
          .maybeSingle() as Map<String, dynamic>?;

      final creditData = await _db
          .from('credit_profiles')
          .select(
              'id, user_id, credit_score, risk_band, '
              'approved_borrowing_limit, model_version, last_assessed_at')
          .eq('user_id', uid)
          .maybeSingle() as Map<String, dynamic>?;

      final badgeRows = (await _db
              .from('user_badges')
              .select(
                  'badge_code, earned_at, is_featured, '
                  'badges(name, description, icon_name)')
              .eq('user_id', uid) as List)
          .cast<Map<String, dynamic>>();

      final statsData = await _db.rpc(
        'get_profile_stats',
        params: {'p_user_id': uid},
      ) as Map<String, dynamic>?;

      final creditProfile = creditData != null
          ? CreditProfileModel.fromJson(creditData)
          : CreditProfileModel.empty;

      final stats = statsData != null
          ? ProfileStatsModel.fromJson(statsData)
          : ProfileStatsModel.empty;

      final badges = badgeRows.map((row) {
        final badgeInfo =
            row['badges'] as Map<String, dynamic>?;
        return BadgeModel.fromJson({
          ...row,
          if (badgeInfo != null) ...badgeInfo,
        });
      }).toList();

      return UserProfileModel(
        userId: uid,
        email: profileData?['email'] as String? ??
            _db.auth.currentUser?.email ?? '',
        fullName: profileData?['full_name'] as String? ?? '',
        reputationScore:
            (profileData?['reputation_score'] as num?)?.toInt() ??
                0,
        memberSince: profileData?['created_at'] != null
            ? DateTime.parse(
                profileData!['created_at'] as String)
            : DateTime.now(),
        location: profileData?['location'] as String?,
        creditProfile: creditProfile,
        stats: stats,
        badges: badges,
      );
    } on PostgrestException catch (e) {
      throw Exception('Failed to load profile: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
          'An unexpected error occurred loading your profile.');
    }
  }
}