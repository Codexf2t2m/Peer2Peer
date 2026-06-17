
// Data boundary for the Community Browse feature.
//
// Reads from LOAN_REQUESTS joined with:
//   PROFILES       → full_name, reputation_score, avatar_seed
//   CREDIT_PROFILES→ credit_score, risk_band
//
// Only active community requests are returned — status = 'active',
// request_type = 'community'.

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/community_member_model.dart';

class CommunityRepository {
  CommunityRepository(this._db);

  final SupabaseClient _db;

  /// Returns all active community loan requests with borrower profile data.
  Future<List<CommunityMemberModel>> fetchCommunityFeed() async {
    try {
      final data = await _db
          .from('loan_requests')
          .select(
            'id, borrower_id, amount_requested, funded_amount, '
            'interest_rate, duration_days, purpose, status, created_at, '
            'profiles!borrower_id('
            '  full_name, reputation_score, avatar_seed, '
            '  credit_profiles(credit_score, risk_band)'
            ')',
          )
          .eq('request_type', 'community')
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return (data as List)
          .map((row) => CommunityMemberModel.fromJson(
              Map<String, dynamic>.from(row as Map)))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(
          'Failed to load community feed: ${e.message}');
    } catch (e) {
      throw Exception(
          'An unexpected error occurred loading the community feed.');
    }
  }
}