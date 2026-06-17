
// Single data boundary for the Complaint feature.
//
// Responsibilities:
//  1. resolveUserByEmail()  — looks up a user UUID from an email address
//                             (the "resolve email → UUID" TODO from the original)
//  2. submitComplaint()     — inserts into COMPLAINTS, returns the created record
//
// The widget never imports Supabase — all network concerns stay here.

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/complaint_model.dart';

class ComplaintRepository {
  ComplaintRepository(this._db);

  final SupabaseClient _db;

  String? get _uid => _db.auth.currentUser?.id;

  // User lookup 

  /// Resolves an email address to a user UUID via the `profiles` table.
  ///
  /// Returns null when no matching user is found — the repository never
  /// throws for a "not found" case, only for real network failures.
  Future<String?> resolveUserByEmail(String email) async {
    if (email.trim().isEmpty) return null;

    try {
      final data = await _db
          .from('profiles')
          .select('id')
          .eq('email', email.trim().toLowerCase())
          .maybeSingle();

      return data?['id'] as String?;
    } on PostgrestException catch (e) {
      throw Exception('Failed to look up user: ${e.message}');
    } catch (e) {
      throw Exception(
          'An unexpected error occurred while looking up the user.');
    }
  }

  // Submission 

  /// Submits a complaint and returns the created [ComplaintModel].
  ///
  /// [againstUserEmail] is resolved to a UUID internally — callers pass
  /// the raw email from the form field and never handle UUID resolution.
  Future<ComplaintModel> submitComplaint({
    required ComplaintType type,
    required String description,
    String? againstUserEmail,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception('You must be signed in to submit a complaint.');
    }

    if (description.trim().length < 20) {
      throw Exception(
          'Please provide at least 20 characters in your description.');
    }

    try {
      // Resolve the against-user email to a UUID if provided.
      String? againstUserId;
      if (againstUserEmail != null &&
          againstUserEmail.trim().isNotEmpty) {
        againstUserId =
            await resolveUserByEmail(againstUserEmail);
        // If the email doesn't match any user we proceed without it —
        // the admin can resolve manually during review.
      }

      final data = await _db
          .from('complaints')
          .insert({
            'user_id': uid,
            'type': type.toApiString(),
            'status': 'open',
            'description': description.trim(),
            if (againstUserId != null)
              'against_user_id': againstUserId,
          })
          .select()
          .single();

      return ComplaintModel.fromJson(
          Map<String, dynamic>.from(data));
    } on PostgrestException catch (e) {
      throw Exception(
          'Failed to submit complaint: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
          'An unexpected error occurred. Please try again.');
    }
  }
}