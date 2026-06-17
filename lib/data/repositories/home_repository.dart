// lib/data/repositories/home_repository.dart
//
// Single data boundary for the Home feature.
//
// Fetches sequentially to avoid Future.wait type-inference issues:
//   1. PROFILES                → display name + wallet balance
//   2. get_lending_overview RPC → total_lent, interest_earned
//   3. TRANSACTIONS            → all + recent slice
//   4. NOTIFICATIONS           → unread list

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/home_overview_model.dart';
import '../models/notification_model.dart';
import '../models/wallet_transaction_model.dart';

class HomeRepository {
  HomeRepository(this._db);

  final SupabaseClient _db;

  String? get _uid => _db.auth.currentUser?.id;

  Future<HomeOverviewModel> fetchHomeOverview() async {
    final uid = _uid;
    if (uid == null) return HomeOverviewModel.empty;

    try {
      // 1. Profile — display name + wallet balance
      final profileData = await _db
          .from('profiles')
          .select('full_name, email, available_lending_amount')
          .eq('id', uid)
          .maybeSingle() as Map<String, dynamic>?;

      final fullName =
          profileData?['full_name'] as String? ?? '';
      final email =
          _db.auth.currentUser?.email ?? '';
      final displayName = fullName.trim().isNotEmpty
          ? fullName.trim().split(' ').first
          : (email.isNotEmpty
              ? '${email.split('@').first[0].toUpperCase()}'
                '${email.split('@').first.substring(1)}'
              : 'there');
      final walletBalance =
          (profileData?['available_lending_amount'] as num?)
                  ?.toDouble() ??
              0;

      // 2. Lending overview RPC
      final overviewData = await _db.rpc(
        'get_lending_overview',
        params: {'p_lender_id': uid},
      ) as Map<String, dynamic>?;

      final totalLent =
          (overviewData?['total_lent'] as num?)?.toDouble() ?? 0;
      final interestEarned =
          (overviewData?['interest_earned'] as num?)?.toDouble() ?? 0;
      final repaymentRate =
          (overviewData?['repayment_rate'] as num?)?.toInt() ?? 0;
      final monthlyDelta =
          (overviewData?['monthly_delta'] as num?)?.toDouble() ?? 0;

      // 3. Transactions — all types, newest first
      final txRows = (await _db
              .from('transactions')
              .select(
                'id, user_id, type, gross_amount, fee_amount, net_amount, '
                'status, created_at, loan_request_id, active_loan_id, '
                'loan_requests(purpose, profiles!borrower_id(full_name))',
              )
              .eq('user_id', uid)
              .order('created_at', ascending: false) as List)
          .cast<Map<String, dynamic>>();

      final allTx = txRows
          .map((r) => WalletTransactionModel.fromJson(r))
          .toList();
      final recentTx = allTx.take(2).toList();

      // 4. Notifications — newest first
      final notifRows = (await _db
              .from('notifications')
              .select()
              .eq('user_id', uid)
              .order('created_at', ascending: false)
              .limit(20) as List)
          .cast<Map<String, dynamic>>();

      final notifications = notifRows
          .map((r) => NotificationModel.fromJson(r))
          .toList();

      return HomeOverviewModel(
        displayName: displayName,
        walletBalance: walletBalance,
        totalLent: totalLent,
        interestEarned: interestEarned,
        repaymentRatePercent: repaymentRate,
        monthlyDeltaPula: monthlyDelta,
        recentTransactions: recentTx,
        allTransactions: allTx,
        notifications: notifications,
      );
    } on PostgrestException catch (e) {
      throw Exception(
          'Failed to load home data: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
          'An unexpected error occurred loading the home screen.');
    }
  }

  /// Searches community members by name or subtitle.
  /// Delegates to LOAN_REQUESTS + PROFILES for live data.
  Future<List<Map<String, dynamic>>> searchBorrowers(
      String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final rows = (await _db
              .from('loan_requests')
              .select(
                'id, purpose, '
                'profiles!borrower_id(full_name, reputation_score)',
              )
              .eq('status', 'active')
              .eq('request_type', 'community')
              .ilike('profiles.full_name', '%${query.trim()}%')
              .limit(10) as List)
          .cast<Map<String, dynamic>>();
      return rows;
    } catch (_) {
      return [];
    }
  }
}