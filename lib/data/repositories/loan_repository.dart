// lib/data/repositories/loan_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/active_loan_model.dart';
import '../models/loan_contribution_model.dart';
import '../models/loan_request_model.dart';

/// Single source of truth for all loan-related data operations.
///
/// Callers receive strongly-typed domain models; all Supabase / network
/// details stay behind this boundary.  View models only talk to this
/// repository — they never import Supabase directly.
///
/// Error handling: every method wraps Postgres and generic errors and
/// rethrows them as plain [Exception]s so the UI layer can display them
/// without depending on Supabase types.
class LoanRepository {
  LoanRepository(this._db);

  final SupabaseClient _db;

  String? get _uid => _db.auth.currentUser?.id;

  // ── Community feed ─────────────────────────────────────────────────────────

  /// Returns all active community loan requests with borrower profile data.
  Future<List<LoanRequestModel>> fetchActiveCommunityRequests() async {
    try {
      final data = await _db
          .from('loan_requests')
          .select(
            'id, borrower_id, request_type, amount_requested, interest_rate, '
            'duration_days, purpose, status, funded_amount, created_at, '
            'profiles!borrower_id(full_name, reputation_score)',
          )
          .eq('request_type', 'community')
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return (data as List)
          .map((row) => LoanRequestModel.fromJson(
              Map<String, dynamic>.from(row as Map)))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(
          'Failed to fetch community loan requests: ${e.message}');
    } catch (e) {
      throw Exception(
          'An unexpected error occurred while loading community requests.');
    }
  }

  /// Returns a single loan request by ID, or null if not found.
  Future<LoanRequestModel?> fetchLoanRequest(String id) async {
    try {
      final data = await _db
          .from('loan_requests')
          .select(
            'id, borrower_id, request_type, amount_requested, interest_rate, '
            'duration_days, purpose, status, funded_amount, created_at, '
            'profiles!borrower_id(full_name, reputation_score)',
          )
          .eq('id', id)
          .maybeSingle();

      return data == null
          ? null
          : LoanRequestModel.fromJson(
              Map<String, dynamic>.from(data));
    } on PostgrestException catch (e) {
      throw Exception('Failed to fetch loan request: ${e.message}');
    } catch (e) {
      throw Exception(
          'An unexpected error occurred while loading the request.');
    }
  }

  // ── Borrower: my loan requests ─────────────────────────────────────────────

  /// Returns all loan requests submitted by the current user.
  Future<List<LoanRequestModel>> fetchMyLoanRequests() async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final data = await _db
          .from('loan_requests')
          .select()
          .eq('borrower_id', uid)
          .order('created_at', ascending: false);

      return (data as List)
          .map((row) => LoanRequestModel.fromJson(
              Map<String, dynamic>.from(row as Map)))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(
          'Failed to fetch your loan requests: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    }
  }

  /// Submits a new loan request and returns the created record.
  Future<LoanRequestModel> submitLoanRequest({
    required double amountRequested,
    required double interestRate,
    required int durationDays,
    String? purpose,
    String requestType = 'community',
    String? targetLenderId,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception(
          'You must be signed in to submit a loan request.');
    }

    try {
      final data = await _db
          .from('loan_requests')
          .insert({
            'borrower_id': uid,
            'request_type': requestType,
            'amount_requested': amountRequested,
            'interest_rate': interestRate,
            'duration_days': durationDays,
            'purpose': purpose,
            'status': 'active',
            'funded_amount': 0.0,
            if (targetLenderId != null)
              'target_lender_id': targetLenderId,
          })
          .select()
          .single();

      return LoanRequestModel.fromJson(
          Map<String, dynamic>.from(data));
    } on PostgrestException catch (e) {
      throw Exception(
          'Failed to submit loan request: ${e.message}');
    } catch (e) {
      throw Exception(
          'An unexpected error occurred while submitting.');
    }
  }

  // ── Borrower: active loans ─────────────────────────────────────────────────

  /// Returns all disbursed loans where the current user is the borrower.
  Future<List<ActiveLoanModel>> fetchMyActiveLoansAsBorrower() async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final data = await _db
          .from('active_loans')
          .select('*, loan_requests(purpose)')
          .eq('borrower_id', uid)
          .order('created_at', ascending: false);

      return (data as List)
          .map((row) => ActiveLoanModel.fromJson(
              Map<String, dynamic>.from(row as Map)))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to fetch active loans: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    }
  }

  // ── Lender: contributions ──────────────────────────────────────────────────

  /// Returns all funding contributions made by the current user.
  Future<List<LoanContributionModel>> fetchMyContributions() async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final data = await _db
          .from('loan_contributions')
          .select(
            '*, loan_requests(purpose, profiles!borrower_id(full_name, email))',
          )
          .eq('lender_id', uid)
          .order('created_at', ascending: false);

      return (data as List)
          .map((row) => LoanContributionModel.fromJson(
              Map<String, dynamic>.from(row as Map)))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(
          'Failed to fetch contributions: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    }
  }

  /// Funds a community loan request via an atomic server-side RPC.
  ///
  /// Caps the contribution at the remaining unfunded amount.
  /// Returns the created [LoanContributionModel] on success.
  Future<LoanContributionModel> fundLoanRequest({
    required String loanRequestId,
    required double amount,
    double platformCutRate = 0.02,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception(
          'You must be signed in to fund a loan request.');
    }

    try {
      // 1. Validate the request is still active and compute amounts.
      final requestData = await _db
          .from('loan_requests')
          .select('amount_requested, funded_amount, interest_rate, status')
          .eq('id', loanRequestId)
          .single();

      final status =
          requestData['status'] as String? ?? '';
      if (status != 'active') {
        throw Exception(
            'This loan request is no longer accepting contributions.');
      }

      final amountRequested =
          (requestData['amount_requested'] as num).toDouble();
      final fundedAmount =
          (requestData['funded_amount'] as num).toDouble();
      final remaining = amountRequested - fundedAmount;

      final actualAmount = amount > remaining ? remaining : amount;
      if (actualAmount <= 0) {
        throw Exception(
            'This loan request is already fully funded.');
      }

      final interestRate =
          (requestData['interest_rate'] as num).toDouble();
      final expectedReturn =
          actualAmount * (1 + interestRate / 100);
      final platformCut = actualAmount * platformCutRate;

      // 2. Execute the atomic stored procedure.
      await _db.rpc('fund_loan_request', params: {
        'p_loan_request_id': loanRequestId,
        'p_lender_id': uid,
        'p_amount': actualAmount,
        'p_expected_return': expectedReturn,
        'p_platform_cut': platformCut,
      });

      // 3. Retrieve the newly created contribution record.
      final contributionData = await _db
          .from('loan_contributions')
          .select()
          .eq('loan_request_id', loanRequestId)
          .eq('lender_id', uid)
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      return LoanContributionModel.fromJson(
          Map<String, dynamic>.from(contributionData));
    } on PostgrestException catch (e) {
      throw Exception('Transaction failed: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
          'An unexpected error occurred during funding.');
    }
  }
}