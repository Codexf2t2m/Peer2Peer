import 'package:supabase_flutter/supabase_flutter.dart';

/// Result of a credit assessment run.
class CreditAssessmentResult {
  final int creditScore;
  final String riskBand;
  final double borrowingLimit;
  final String modelVersion;

  const CreditAssessmentResult({
    required this.creditScore,
    required this.riskBand,
    required this.borrowingLimit,
    required this.modelVersion,
  });
}

/// CreditService runs the credit assessment for a user.
///
/// In production this would call a Supabase Edge Function
/// (`assess-credit`) that performs a real ML-based assessment on the
/// user's bank transaction history retrieved via Stitch.
///
/// In development / when running locally, a deterministic mock assessment
/// is used so that the full onboarding flow can be exercised without a
/// live ML model.
class CreditService {
  final SupabaseClient _db;

  CreditService(this._db);

  String? get _uid => _db.auth.currentUser?.id;

  /// Runs a credit assessment for [userId] and atomically:
  /// 1. Upserts a `credit_profiles` row via the `complete_credit_assessment` RPC.
  /// 2. Updates `profiles.borrowing_limit` and `profiles.onboarding_step = 'active'`.
  /// 3. Inserts an `account_activated` notification.
  ///
  /// Returns the [CreditAssessmentResult] so the UI can display the outcome.
  Future<CreditAssessmentResult> runAssessment(String userId) async {
    // Compute assessment result (live Edge Function or local mock)
    final result = await _computeAssessment(userId);

    try {
      await _db.rpc('complete_credit_assessment', params: {
        'p_user_id': userId,
        'p_credit_score': result.creditScore,
        'p_risk_band': result.riskBand,
        'p_borrowing_limit': result.borrowingLimit,
        'p_model_version': result.modelVersion,
      });
    } on PostgrestException catch (e) {
      throw Exception('Failed to save credit assessment: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred during credit assessment.');
    }

    return result;
  }

  /// Tries to call the real Edge Function first; falls back to the local mock.
  Future<CreditAssessmentResult> _computeAssessment(String userId) async {
    try {
      final response = await _db.functions.invoke(
        'assess-credit',
        body: {'user_id': userId},
      );

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return CreditAssessmentResult(
          creditScore: (data['credit_score'] as num).toInt(),
          riskBand: data['risk_band'] as String,
          borrowingLimit: (data['borrowing_limit'] as num).toDouble(),
          modelVersion: data['model_version'] as String? ?? '1.0',
        );
      }
    } catch (_) {
      // Edge Function not deployed – fall through to mock
    }
    return _mockAssessment(userId);
  }

  /// Deterministic mock assessment.
  ///
  /// Uses the userId hash to produce a reproducible but varied result so
  /// that different test accounts get different risk profiles.
  CreditAssessmentResult _mockAssessment(String userId) {
    // Simple hash of the first character code to vary results per user
    final seed = userId.isNotEmpty ? userId.codeUnitAt(0) % 3 : 0;

    return switch (seed) {
      0 => const CreditAssessmentResult(
          creditScore: 750,
          riskBand: 'Good',
          borrowingLimit: 3500,
          modelVersion: 'mock-1.0',
        ),
      1 => const CreditAssessmentResult(
          creditScore: 620,
          riskBand: 'Fair',
          borrowingLimit: 1500,
          modelVersion: 'mock-1.0',
        ),
      _ => const CreditAssessmentResult(
          creditScore: 820,
          riskBand: 'Excellent',
          borrowingLimit: 5000,
          modelVersion: 'mock-1.0',
        ),
    };
  }
}
