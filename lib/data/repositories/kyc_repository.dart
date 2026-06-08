import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Model for a KYC document row.
class KycDocumentModel {
  final String id;
  final String userId;
  final String documentType;
  final String documentUrl;
  final String status;
  final String? reviewNotes;
  final DateTime createdAt;

  const KycDocumentModel({
    required this.id,
    required this.userId,
    required this.documentType,
    required this.documentUrl,
    required this.status,
    this.reviewNotes,
    required this.createdAt,
  });

  factory KycDocumentModel.fromJson(Map<String, dynamic> json) {
    return KycDocumentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      documentType: json['document_type'] as String,
      documentUrl: json['document_url'] as String,
      status: json['status'] as String? ?? 'pending',
      reviewNotes: json['review_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class KycRepository {
  final SupabaseClient _db;

  KycRepository(this._db);

  String? get _uid => _db.auth.currentUser?.id;

  /// Uploads a document file to Supabase Storage then inserts a record into
  /// `kyc_documents`. Also advances `onboarding_step` to `kyc_uploaded`.
  ///
  /// [fileBytes]     Raw bytes of the file.
  /// [fileName]      Original file name (used for MIME detection).
  /// [documentType]  e.g. 'national_id', 'passport', 'utility_bill'.
  Future<KycDocumentModel> uploadDocument({
    required Uint8List fileBytes,
    required String fileName,
    required String documentType,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('User must be signed in to upload a document.');

    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
    final storagePath = '$uid/$documentType.$ext';

    String publicUrl;
    try {
      await _db.storage.from('kyc-documents').uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: _mimeType(ext),
            ),
          );
      publicUrl = _db.storage.from('kyc-documents').getPublicUrl(storagePath);
    } catch (e) {
      throw Exception('Failed to upload document to storage: $e');
    }

    // Insert the database record
    try {
      final Map<String, dynamic> data = await _db
          .from('kyc_documents')
          .insert({
            'user_id': uid,
            'document_type': documentType,
            'document_url': publicUrl,
            'status': 'pending',
          })
          .select()
          .single();

      // Advance onboarding step
      await _db.from('profiles').update({
        'onboarding_step': 'kyc_uploaded',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', uid);

      return KycDocumentModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw Exception('Failed to save KYC document record: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred while saving your document.');
    }
  }

  /// Returns all KYC documents for the current user.
  Future<List<KycDocumentModel>> fetchMyDocuments() async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final List<Map<String, dynamic>> data = await _db
          .from('kyc_documents')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);

      return data.map((row) => KycDocumentModel.fromJson(row)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to load KYC documents: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred while loading your documents.');
    }
  }

  static String _mimeType(String ext) {
    return switch (ext) {
      'pdf' => 'application/pdf',
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'heic' => 'image/heic',
      _ => 'application/octet-stream',
    };
  }
}
