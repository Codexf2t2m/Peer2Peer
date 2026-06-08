import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/badge_model.dart';
import '../models/credit_profile_model.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final SupabaseClient _db;

  ProfileRepository(this._db);

  String? get _uid => _db.auth.currentUser?.id;

  // ── Profile ────────────────────────────────────────────────────────────────

  Future<ProfileModel?> fetchCurrentProfile() async {
    final uid = _uid;
    if (uid == null) return null;

    try {
      final Map<String, dynamic>? data = await _db
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();

      return data == null ? null : ProfileModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw Exception('Failed to load profile: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred while loading profile.');
    }
  }

  /// Returns the current onboarding step for the signed-in user.
  /// Defaults to 'active' if the column is absent (legacy rows).
  Future<String> fetchOnboardingStep() async {
    final uid = _uid;
    if (uid == null) return 'active';

    try {
      final Map<String, dynamic>? data = await _db
          .from('profiles')
          .select('onboarding_step')
          .eq('id', uid)
          .maybeSingle();

      return (data?['onboarding_step'] as String?) ?? 'active';
    } on PostgrestException catch (e) {
      throw Exception('Failed to load onboarding step: ${e.message}');
    } catch (e) {
      return 'active'; // fail-open so users are never blocked
    }
  }

  /// Updates the onboarding step for the signed-in user.
  Future<void> updateOnboardingStep(String step) async {
    final uid = _uid;
    if (uid == null) throw Exception('User must be logged in to update onboarding step.');

    try {
      await _db.from('profiles').update({
        'onboarding_step': step,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', uid);
    } on PostgrestException catch (e) {
      throw Exception('Failed to update onboarding step: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred while updating onboarding step.');
    }
  }

  Future<ProfileModel> updateProfile({
    String? fullName,
    String? phone,
    String? location,
    String? lendingMode,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception('User must be logged in to update profile.');
    }

    final updates = <String, dynamic>{
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (location != null) 'location': location,
      if (lendingMode != null) 'lending_mode': lendingMode,
    };

    try {
      final Map<String, dynamic> data = await _db
          .from('profiles')
          .update(updates)
          .eq('id', uid)
          .select()
          .single();

      return ProfileModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw Exception('Failed to update profile: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred while updating profile.');
    }
  }

  // ── Credit profile ─────────────────────────────────────────────────────────

  Future<CreditProfileModel?> fetchCreditProfile() async {
    final uid = _uid;
    if (uid == null) return null;

    try {
      final Map<String, dynamic>? data = await _db
          .from('credit_profiles')
          .select()
          .eq('user_id', uid)
          .maybeSingle();

      return data == null ? null : CreditProfileModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw Exception('Failed to load credit profile: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred while loading credit profile.');
    }
  }

  // ── Badges ─────────────────────────────────────────────────────────────────

  Future<List<UserBadgeModel>> fetchUserBadges() async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final List<Map<String, dynamic>> data = await _db
          .from('user_badges')
          .select('*, badges(*)')
          .eq('user_id', uid)
          .order('earned_at', ascending: false);

      return data.map((row) => UserBadgeModel.fromJson(row)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to load badges: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred while loading badges.');
    }
  }

  // ── Loan stats for profile screen ──────────────────────────────────────────

  /// Returns a map: { 'total_requested', 'fully_repaid', 'people_funded', 'late_payments' }
  Future<Map<String, int>> fetchProfileStats() async {
    final uid = _uid;
    if (uid == null) {
      return {
        'total_requested': 0,
        'fully_repaid': 0,
        'people_funded': 0,
        'late_payments': 0,
      };
    }

    try {
      final List<Map<String, dynamic>> loanRequestsData = await _db
          .from('loan_requests')
          .select('status')
          .eq('borrower_id', uid);

      final List<Map<String, dynamic>> contributionsData = await _db
          .from('loan_contributions')
          .select('loan_request_id, status')
          .eq('lender_id', uid);

      final List<Map<String, dynamic>> activeLoansData = await _db
          .from('active_loans')
          .select('status, due_date')
          .eq('borrower_id', uid);

      final totalRequested = loanRequestsData.length;
      final fullyRepaid = loanRequestsData
          .where((r) => r['status'] == 'completed')
          .length;

      // Count distinct borrowers the current user funded
      final fundedLoanIds =
          contributionsData.map((c) => c['loan_request_id'] as String).toSet();
      final peopleFunded = fundedLoanIds.length;

      // Count active loans whose due_date has passed (late)
      final now = DateTime.now();
      final latePayments = activeLoansData
          .where((l) {
            if (l['status'] != 'active') return false;
            final due = DateTime.tryParse(l['due_date'] as String? ?? '');
            return due != null && due.isBefore(now);
          })
          .length;

      return {
        'total_requested': totalRequested,
        'fully_repaid': fullyRepaid,
        'people_funded': peopleFunded,
        'late_payments': latePayments,
      };
    } on PostgrestException catch (e) {
      throw Exception('Failed to load profile statistics: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred while loading profile statistics.');
    }
  }

  // ── Wallet balance (derived from transactions) ─────────────────────────────

  /// Computes available balance from completed transactions.
  Future<double> fetchWalletBalance() async {
    final uid = _uid;
    if (uid == null) return 0;

    try {
      final List<Map<String, dynamic>> data = await _db
          .from('transactions')
          .select('type, net_amount')
          .eq('user_id', uid)
          .eq('status', 'completed');

      double balance = 0;
      for (final row in data) {
        final type = row['type'] as String? ?? '';
        final amount = (row['net_amount'] as num?)?.toDouble() ?? 0;
        if (type == 'deposit' || type == 'repayment' || type == 'interest') {
          balance += amount;
        } else if (type == 'funding' || type == 'withdrawal' || type == 'fee') {
          balance -= amount;
        }
      }
      return balance < 0 ? 0 : balance;
    } on PostgrestException catch (e) {
      throw Exception('Failed to load wallet balance: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred while loading wallet balance.');
    }
  }

  // ── Lending overview ───────────────────────────────────────────────────────

  /// Returns { 'total_lent', 'interest_earned' } for the lend overview cards.
  Future<Map<String, double>> fetchLendingOverview() async {
    final uid = _uid;
    if (uid == null) return {'total_lent': 0, 'interest_earned': 0};

    try {
      final List<Map<String, dynamic>> contributions = await _db
          .from('loan_contributions')
          .select('amount_contributed, expected_return, platform_cut, status')
          .eq('lender_id', uid);

      double totalLent = 0;
      double interestEarned = 0;

      for (final row in contributions) {
        final contributed = (row['amount_contributed'] as num?)?.toDouble() ?? 0;
        final expected = (row['expected_return'] as num?)?.toDouble() ?? 0;
        final fee = (row['platform_cut'] as num?)?.toDouble() ?? 0;
        totalLent += contributed;
        if ((row['status'] as String?) == 'completed') {
          interestEarned += expected - contributed - fee;
        }
      }

      return {'total_lent': totalLent, 'interest_earned': interestEarned};
    } on PostgrestException catch (e) {
      throw Exception('Failed to load lending overview: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred while loading lending overview.');
    }
  }
}
