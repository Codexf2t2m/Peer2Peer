// lib/data/repositories/lend_repository.dart
//
// Single data boundary for the Lend feature.
// Reads from:
//   - TRANSACTIONS  (type IN ('funding','repayment'), joined with loan_requests + profiles)
//   - An RPC / view for the portfolio overview aggregate
//
// The view model is the only caller — it never imports Supabase.

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lending_activity_model.dart';
import '../models/lending_overview_model.dart';

class LendRepository {
  LendRepository(this._db);

  final SupabaseClient _db;

  String? get _uid => _db.auth.currentUser?.id;

  // ── Portfolio overview ──────────────────────────────────────────────────────

  /// Returns a single [LendingOverviewModel] for the current lender.
  ///
  /// Calls the `get_lending_overview` Postgres function which aggregates
  /// LOAN_CONTRIBUTIONS rows for the current user.
  Future<LendingOverviewModel> fetchLendingOverview() async {
    final uid = _uid;
    if (uid == null) return LendingOverviewModel.empty;

    try {
      final data = await _db
          .rpc('get_lending_overview', params: {'p_lender_id': uid});

      if (data == null) return LendingOverviewModel.empty;

      return LendingOverviewModel.fromJson(
          Map<String, dynamic>.from(data as Map));
    } on PostgrestException catch (e) {
      throw Exception('Failed to load lending overview: ${e.message}');
    } catch (e) {
      throw Exception(
          'An unexpected error occurred while loading your portfolio.');
    }
  }

  // ── Lending activity ────────────────────────────────────────────────────────

  /// Returns all funding and repayment transactions for the current lender,
  /// newest first, joined with loan purpose and borrower name.
  Future<List<LendingActivityModel>> fetchLendingActivity() async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final data = await _db
          .from('transactions')
          .select(
            'id, type, gross_amount, net_amount, fee_amount, status, '
            'created_at, active_loan_id, loan_request_id, '
            'loan_requests(purpose, profiles!borrower_id(full_name))',
          )
          .eq('user_id', uid)
          .inFilter('type', ['funding', 'repayment'])
          .order('created_at', ascending: false);

      return (data as List)
          .map((row) => LendingActivityModel.fromJson(
              Map<String, dynamic>.from(row as Map)))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(
          'Failed to load lending activity: ${e.message}');
    } catch (e) {
      throw Exception(
          'An unexpected error occurred while loading activity.');
    }
  }
}