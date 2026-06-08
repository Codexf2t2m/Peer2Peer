import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/active_loan_model.dart';
import '../models/loan_contribution_model.dart';
import '../models/loan_request_model.dart';

class LoanRepository {
  final SupabaseClient _db;

  LoanRepository(this._db);

  String? get _uid => _db.auth.currentUser?.id;

  // ── Community feed ─────────────────────────────────────────────────────────

  /// Fetches active community loan requests visible to any authenticated user.
  /// Joins the borrower's public profile fields (name, reputation_score).
  Future<List<LoanRequestModel>> fetchActiveCommunityRequests() async {
    try {
      final List<Map<String, dynamic>> data = await _db
          .from('loan_requests')
          .select(
            'id, borrower_id, request_type, amount_requested, interest_rate, '
            'duration_days, purpose, status, funded_amount, created_at, '
            'profiles!borrower_id(full_name, reputation_score)',
          )
          .eq('request_type', 'community')
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return data.map((row) => LoanRequestModel.fromJson(row)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to fetch community loan requests: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred while loading community requests.');
    }
  }

  /// Fetches a single loan request by ID with borrower profile data.
  Future<LoanRequestModel?> fetchLoanRequest(String id) async {
    try {
      final Map<String, dynamic>? data = await _db
          .from('loan_requests')
          .select(
            'id, borrower_id, request_type, amount_requested, interest_rate, '
            'duration_days, purpose, status, funded_amount, created_at, '
            'profiles!borrower_id(full_name, reputation_score)',
          )
          .eq('id', id)
          .maybeSingle();

      return data == null ? null : LoanRequestModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw Exception('Failed to fetch loan request: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred while loading the request.');
    }
  }

  // ── Borrower: my loan requests ─────────────────────────────────────────────

  Future<List<LoanRequestModel>> fetchMyLoanRequests() async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final List<Map<String, dynamic>> data = await _db
          .from('loan_requests')
          .select()
          .eq('borrower_id', uid)
          .order('created_at', ascending: false);

      return data.map((row) => LoanRequestModel.fromJson(row)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to fetch your loan requests: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred.');
    }
  }

  /// Submits a new community or direct loan request.
  Future<LoanRequestModel> submitLoanRequest({
    required double amountRequested,
    required double interestRate,
    required int durationDays,
    String? purpose,
    String requestType = 'community',
    String? targetLenderId,
    String initialStatus = 'active',
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception('User must be logged in to submit a loan request.');
    }

    try {
      final Map<String, dynamic> data = await _db
          .from('loan_requests')
          .insert({
            'borrower_id': uid,
            'request_type': requestType,
            'amount_requested': amountRequested,
            'interest_rate': interestRate,
            'duration_days': durationDays,
            'purpose': purpose,
            'status': initialStatus,
            'funded_amount': 0.0,
            if (targetLenderId != null) 'target_lender_id': targetLenderId,
          })
          .select()
          .single();

      return LoanRequestModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw Exception('Failed to submit loan request: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred while submitting.');
    }
  }

  // ── Lender: my active loans ────────────────────────────────────────────────

  Future<List<ActiveLoanModel>> fetchMyActiveLoansAsBorrower() async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final List<Map<String, dynamic>> data = await _db
          .from('active_loans')
          .select('*, loan_requests(purpose)')
          .eq('borrower_id', uid)
          .order('created_at', ascending: false);

      return data.map((row) => ActiveLoanModel.fromJson(row)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to fetch active loans: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred.');
    }
  }

  // ── Lender: my contributions ───────────────────────────────────────────────

  Future<List<LoanContributionModel>> fetchMyContributions() async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final List<Map<String, dynamic>> data = await _db
          .from('loan_contributions')
          .select(
            '*, loan_requests(purpose, profiles!borrower_id(full_name, email))',
          )
          .eq('lender_id', uid)
          .order('created_at', ascending: false);

      return data.map((row) => LoanContributionModel.fromJson(row)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to fetch contributions: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred.');
    }
  }

  /// Funds a loan request by executing the atomic PostgreSQL RPC function.
  Future<LoanContributionModel?> fundLoanRequest({
    required String loanRequestId,
    required double amount,
    double platformCutRate = 0.02,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception('User must be logged in to fund a request.');
    }

    try {
      // 1. Fetch current request to validate and compute expected return/cuts
      final Map<String, dynamic> requestData = await _db
          .from('loan_requests')
          .select('amount_requested, funded_amount, interest_rate, status')
          .eq('id', loanRequestId)
          .single();

      final status = requestData['status'] as String? ?? '';
      if (status != 'active') {
        throw Exception('This loan request is no longer active.');
      }

      final amountRequested = (requestData['amount_requested'] as num).toDouble();
      final fundedAmount = (requestData['funded_amount'] as num).toDouble();
      final remaining = amountRequested - fundedAmount;

      // Cap contribution at remaining amount
      final actualAmount = amount > remaining ? remaining : amount;
      if (actualAmount <= 0) {
        throw Exception('This loan request is already fully funded.');
      }

      final interestRate = (requestData['interest_rate'] as num).toDouble();
      final expectedReturn = actualAmount * (1 + interestRate / 100);
      final platformCut = actualAmount * platformCutRate;

      // 2. Call the server-side atomic PostgreSQL stored procedure
      await _db.rpc('fund_loan_request', params: {
        'p_loan_request_id': loanRequestId,
        'p_lender_id': uid,
        'p_amount': actualAmount,
        'p_expected_return': expectedReturn,
        'p_platform_cut': platformCut,
      });

      // 3. Retrieve the created contribution record to return
      final Map<String, dynamic> contributionData = await _db
          .from('loan_contributions')
          .select()
          .eq('loan_request_id', loanRequestId)
          .eq('lender_id', uid)
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      return LoanContributionModel.fromJson(contributionData);
    } on PostgrestException catch (e) {
      throw Exception('Transaction failed: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected network error occurred during funding.');
    }
  }
}
