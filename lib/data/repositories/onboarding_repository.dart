// lib/data/repositories/onboarding_repository.dart
//
// Single data boundary for the entire onboarding flow.
//
// Covers all four steps:
//   1. confirmEmailVerified()   — UC: Verify Email
//   2. connectBank()            — UC: Connect Bank Account (via Stitch)
//   3. uploadKycDocument()      — UC: Upload KYC Documents
//   4. runCreditAssessment()    — UC: Run Credit Assessment
//
// The onboarding_step column on PROFILES tracks progress server-side.
// Each step calls the appropriate RPC to advance the step and never
// lets the client decide what step the user is on.

import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/credit_assessment_result_model.dart';
import '../models/kyc_document_model.dart';

class OnboardingRepository {
  OnboardingRepository(this._db);

  final SupabaseClient _db;

  String? get _uid => _db.auth.currentUser?.id;

  // ── Step 1: Email verification ───────────────────────────────────────────

  /// Refreshes the session and checks if the email is confirmed.
  ///
  /// Returns true when `email_confirmed_at` is set on the auth user.
  Future<bool> confirmEmailVerified() async {
    try {
      await _db.auth.refreshSession();
      final user = _db.auth.currentUser;
      final confirmed = user?.emailConfirmedAt != null;

      if (confirmed && _uid != null) {
        // Advance onboarding_step → 'email_verified'
        await _db.rpc('advance_onboarding_step', params: {
          'p_user_id': _uid,
          'p_step': 'email_verified',
        });
      }
      return confirmed;
    } on AuthException catch (e) {
      throw Exception('Could not verify email: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred.');
    }
  }

  /// Resends the confirmation email to the current user.
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _db.auth
          .resend(type: OtpType.signup, email: email);
    } on AuthException catch (e) {
      throw Exception(
          'Could not resend email: ${e.message}');
    } catch (e) {
      throw Exception(
          'An unexpected error occurred while resending.');
    }
  }

  // ── Step 2: Bank connection ───────────────────────────────────────────────

  /// Records a bank connection after the Stitch OAuth callback.
  ///
  /// In production, [accountIdExternal] is the account ID from the
  /// Stitch token exchange. Here the caller passes a mock ID during
  /// development.
  Future<void> connectBank({
    required String provider,
    required String bankName,
    required String accountIdExternal,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in.');

    try {
      await _db.from('bank_connections').insert({
        'user_id': uid,
        'provider': provider,
        'bank_name': bankName,
        'account_id_external': accountIdExternal,
        'connection_status': 'active',
        'connected_at': DateTime.now().toIso8601String(),
      });

      await _db.rpc('advance_onboarding_step', params: {
        'p_user_id': uid,
        'p_step': 'bank_connected',
      });
    } on PostgrestException catch (e) {
      throw Exception(
          'Failed to connect bank: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred.');
    }
  }

  // ── Step 3: KYC document upload ──────────────────────────────────────────

  /// Uploads [fileBytes] to Supabase Storage and inserts a kyc_documents row.
  Future<KycDocumentModel> uploadKycDocument({
    required Uint8List fileBytes,
    required String fileName,
    required KycDocumentType documentType,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in.');

    try {
      // 1. Upload to storage bucket 'kyc-documents'
      final storagePath = '$uid/$fileName';
      await _db.storage.from('kyc-documents').uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final storageUrl = _db.storage
          .from('kyc-documents')
          .getPublicUrl(storagePath);

      // 2. Insert the KYC document record
      final data = await _db
          .from('kyc_documents')
          .insert({
            'user_id': uid,
            'document_type': documentType.apiValue,
            'storage_url': storageUrl,
            'status': 'pending',
          })
          .select()
          .single() as Map<String, dynamic>;

      // 3. Advance onboarding step
      await _db.rpc('advance_onboarding_step', params: {
        'p_user_id': uid,
        'p_step': 'kyc_uploaded',
      });

      return KycDocumentModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw Exception(
          'Failed to upload document: ${e.message}');
    } on StorageException catch (e) {
      throw Exception(
          'Storage upload failed: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
          'An unexpected error occurred during upload.');
    }
  }

  // ── Step 4: Credit assessment ─────────────────────────────────────────────

  /// Runs the credit assessment RPC and returns the result.
  ///
  /// The RPC reads the user's bank transactions (from BANK_TRANSACTIONS),
  /// computes a score, inserts into CREDIT_PROFILES, and advances
  /// onboarding_step → 'active'.
  Future<CreditAssessmentResultModel> runCreditAssessment() async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in.');

    try {
      final data = await _db.rpc(
        'run_credit_assessment',
        params: {'p_user_id': uid},
      ) as Map<String, dynamic>?;

      if (data == null) {
        throw Exception(
            'Credit assessment returned no result.');
      }

      return CreditAssessmentResultModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw Exception(
          'Credit assessment failed: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
          'An unexpected error occurred during assessment.');
    }
  }

  // ── Splash: onboarding step lookup ────────────────────────────────────────

  /// Returns the current user's onboarding_step from PROFILES.
  ///
  /// Used by the splash screen to route to the correct onboarding step
  /// on app launch. Defaults to 'pending_verification' if the column
  /// is somehow null (e.g. a row created before the column existed).
  Future<String> fetchOnboardingStep() async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in.');

    try {
      final data = await _db
          .from('profiles')
          .select('onboarding_step')
          .eq('id', uid)
          .maybeSingle() as Map<String, dynamic>?;

      return data?['onboarding_step'] as String? ??
          'pending_verification';
    } on PostgrestException catch (e) {
      throw Exception(
          'Failed to load onboarding status: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred.');
    }
  }
}