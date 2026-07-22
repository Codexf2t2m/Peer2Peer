
// Data boundary for the Kutlo AI feature.
//
// Two responsibilities:
//  1. fetchUserContext() — assembles the financial snapshot from
//     PROFILES + CREDIT_PROFILES + ACTIVE_LOANS + LOAN_CONTRIBUTIONS
//     so Kutlo has grounded data to reason about.
//
//  2. sendMessage() — calls the `kutlo_chat` Supabase Edge Function,
//     passing the full conversation history + system context.
//     Returns the assistant's reply as a plain string.
//
// The Edge Function is responsible for:
//   - Calling the AI provider (Claude / OpenAI)
//   - Rate limiting
//   - Logging interactions
//   - Keeping the API key server-side (never in the client)

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kutlo_context_model.dart';
import '../models/kutlo_message_model.dart';

class KutloRepository {
  KutloRepository(this._db);

  final SupabaseClient _db;

  String? get _uid => _db.auth.currentUser?.id;

  // User context 

  /// Builds a [KutloContextModel] from the current user's live data.
  ///
  /// Runs three queries in parallel for speed:
  ///    1. PROFILES join CREDIT_PROFILES
  ///    2. ACTIVE_LOANS aggregate
  ///    3. LOAN_CONTRIBUTIONS aggregate
  Future<KutloContextModel> fetchUserContext() async {
    final uid = _uid;
    if (uid == null) return KutloContextModel.empty;

    try {
      // Fixed: Explicitly typed Future.wait and executed the queries immediately
      final results = await Future.wait<dynamic>([
        // 1. Profile + credit profile
        _db
            .from('profiles')
            .select(
              'full_name, available_lending_amount, borrowing_limit, '
              'credit_profiles(credit_score, risk_band, approved_borrowing_limit)',
            )
            .eq('id', uid)
            .maybeSingle(),

        // 2. Active loans aggregate
        _db
            .from('active_loans')
            .select('principal, total_repayment_amount')
            .eq('borrower_id', uid)
            .eq('status', 'active'),

        // 3. Lender contributions aggregate
        _db
            .from('loan_contributions')
            .select('amount_contributed')
            .eq('lender_id', uid)
            .eq('status', 'funded'),
      ]);

      final profile =
          results[0] as Map<String, dynamic>?;
      final activeLoans =
          (results[1] as List).cast<Map<String, dynamic>>();
      final contributions =
          (results[2] as List).cast<Map<String, dynamic>>();

      final creditProfile =
          profile?['credit_profiles'] as Map<String, dynamic>?;

      final totalOutstanding = activeLoans.fold<double>(
        0,
        (sum, l) =>
            sum +
            ((l['total_repayment_amount'] as num?)?.toDouble() ?? 0),
      );

      final totalDeployed = contributions.fold<double>(
        0,
        (sum, c) =>
            sum +
            ((c['amount_contributed'] as num?)?.toDouble() ?? 0),
      );

      return KutloContextModel(
        userName: profile?['full_name'] as String? ?? 'User',
        availableBalance:
            (profile?['available_lending_amount'] as num?)
                    ?.toDouble() ??
                0,
        availableLendingAmount:
            (profile?['available_lending_amount'] as num?)
                    ?.toDouble() ??
                0,
        borrowingLimit:
            (profile?['borrowing_limit'] as num?)?.toDouble() ?? 0,
        creditScore:
            (creditProfile?['credit_score'] as num?)?.toInt() ?? 0,
        riskBand:
            creditProfile?['risk_band'] as String? ?? 'unknown',
        approvedBorrowingLimit:
            (creditProfile?['approved_borrowing_limit'] as num?)
                    ?.toDouble() ??
                0,
        activeLoansCount: activeLoans.length,
        totalOutstanding: totalOutstanding,
        totalDeployed: totalDeployed,
      );
    } on PostgrestException catch (e) {
      throw Exception(
          'Failed to load your financial context: ${e.message}');
    } catch (e) {
      throw Exception(
          'An unexpected error occurred loading your profile.');
    }
  }

  // AI conversation 

  /// Sends [history] (including the latest user message) to the
  /// `kutlo_chat` Edge Function and returns the assistant reply.
  ///
  /// [context] is serialised into the system prompt by the Edge Function.
  Future<String> sendMessage({
    required List<KutloMessageModel> history,
    required KutloContextModel context,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception('You must be signed in to use Kutlo.');
    }

    try {
      final response = await _db.functions.invoke(
        'kutlo_chat',
        body: {
          'user_id': uid,
          'messages': history.map((m) => m.toApiMessage()).toList(),
          'context': context.toSystemPromptBlock(),
        },
      );

      if (response.status != 200) {
        throw Exception(
            'Kutlo is unavailable right now. Please try again.');
      }

      final data = response.data as Map<String, dynamic>?;
      final reply = data?['reply'] as String?;

      if (reply == null || reply.trim().isEmpty) {
        throw Exception('Kutlo returned an empty response.');
      }

      return reply.trim();
    } on FunctionException catch (e) {
      throw Exception('Kutlo error: ${e.reasonPhrase}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
          'An unexpected error occurred contacting Kutlo.');
    }
  }
}