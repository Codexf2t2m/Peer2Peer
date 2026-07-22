
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/badge_model.dart';
import '../models/borrower_profile_model.dart';

class CommunityFundRepository {
  CommunityFundRepository(this._db);

  final SupabaseClient _db;

  String? get _uid => _db.auth.currentUser?.id;

  // Borrower profile 

  Future<BorrowerProfileModel> fetchBorrowerProfile(
      String loanRequestId) async {
    try {
      // 1. Loan request with nested profile + credit profile.
      final raw = await _db
          .from('loan_requests')
          .select(
            'id, borrower_id, amount_requested, funded_amount, '
            'interest_rate, duration_days, purpose, '
            'profiles!borrower_id('
            '  full_name, about, reputation_score, avatar_seed, '
            '  credit_profiles(credit_score, risk_band)'
            ')',
          )
          .eq('id', loanRequestId)
          .single();

      final loanData = Map<String, dynamic>.from(raw);
      final borrowerId = loanData['borrower_id'] as String;

      // 2. Badges for this borrower — fetched after borrower_id is known.
      final badgeData = await _db
          .from('user_badges')
          .select(
              'badge_code, earned_at, is_featured, badges(name, description, icon_name)')
          .eq('user_id', borrowerId);

      final badges = (badgeData as List).map((b) {
        final row = Map<String, dynamic>.from(b as Map);
        final badgeInfo = row['badges'] as Map<String, dynamic>?;
        return BadgeModel.fromJson({
          ...row,
          if (badgeInfo != null) ...badgeInfo,
        });
      }).toList();

      return BorrowerProfileModel.fromJson(loanData, badges);
    } on PostgrestException catch (e) {
      throw Exception(
          'Failed to load borrower profile: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
          'An unexpected error occurred loading this profile.');
    }
  }

  // Wallet balance 

  Future<double> fetchWalletBalance() async {
    final uid = _uid;
    if (uid == null) return 0;

    try {
      final data = await _db
          .from('profiles')
          .select('available_lending_amount')
          .eq('id', uid)
          .single();

      return (data['available_lending_amount'] as num?)?.toDouble() ?? 0;
    } on PostgrestException catch (e) {
      throw Exception('Failed to load wallet balance: ${e.message}');
    } catch (_) {
      return 0;
    }
  }

  // Fund mutation 

  Future<void> fundLoan({
    required String loanRequestId,
    required double amount,
    double platformCutRate = 0.02,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception('You must be signed in to fund a loan.');
    }
    if (amount <= 0) {
      throw Exception('Please enter an amount greater than zero.');
    }

    try {
      final requestData = await _db
          .from('loan_requests')
          .select('amount_requested, funded_amount, interest_rate, status')
          .eq('id', loanRequestId)
          .single();

      if ((requestData['status'] as String?) != 'active') {
        throw Exception(
            'This loan request is no longer accepting contributions.');
      }

      final amountRequested =
          (requestData['amount_requested'] as num).toDouble();
      final fundedAmount =
          (requestData['funded_amount'] as num).toDouble();
      final remaining = amountRequested - fundedAmount;

      final actual = amount > remaining ? remaining : amount;
      if (actual <= 0) {
        throw Exception('This loan request is already fully funded.');
      }

      final interestRate =
          (requestData['interest_rate'] as num).toDouble();
      final expectedReturn = actual * (1 + interestRate / 100);
      final platformCut = actual * platformCutRate;

      await _db.rpc('fund_loan_request', params: {
        'p_loan_request_id': loanRequestId,
        'p_lender_id': uid,
        'p_amount': actual,
        'p_expected_return': expectedReturn,
        'p_platform_cut': platformCut,
      });
    } on PostgrestException catch (e) {
      throw Exception('Funding failed: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred.');
    }
  }
}