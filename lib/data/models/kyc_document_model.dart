
// Maps to the KYC_DOCUMENTS table (implied by the UML's Upload KYC Documents UC).
//
// UC: Upload KYC Documents

/// Document types accepted for KYC verification.
enum KycDocumentType {
  nationalId,
  passport,
  driversLicence;

  String get apiValue => switch (this) {
        KycDocumentType.nationalId => 'national_id',
        KycDocumentType.passport => 'passport',
        KycDocumentType.driversLicence => 'drivers_licence',
      };

  String get label => switch (this) {
        KycDocumentType.nationalId => 'National ID',
        KycDocumentType.passport => 'Passport',
        KycDocumentType.driversLicence => "Driver's Licence",
      };

  static KycDocumentType fromString(String value) => switch (value) {
        'national_id' => KycDocumentType.nationalId,
        'passport' => KycDocumentType.passport,
        'drivers_licence' => KycDocumentType.driversLicence,
        _ => KycDocumentType.nationalId,
      };
}

/// Status of a submitted KYC document.
enum KycStatus {
  pending,
  approved,
  rejected;

  static KycStatus fromString(String value) => switch (value) {
        'approved' => KycStatus.approved,
        'rejected' => KycStatus.rejected,
        _ => KycStatus.pending,
      };
}

/// Immutable record of an uploaded KYC document.
class KycDocumentModel {
  const KycDocumentModel({
    required this.id,
    required this.userId,
    required this.documentType,
    required this.storageUrl,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final KycDocumentType documentType;
  final String storageUrl;
  final KycStatus status;
  final DateTime createdAt;

  bool get isPending => status == KycStatus.pending;
  bool get isApproved => status == KycStatus.approved;

  factory KycDocumentModel.fromJson(Map<String, dynamic> json) {
    return KycDocumentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      documentType: KycDocumentType.fromString(
          json['document_type'] as String? ?? 'national_id'),
      storageUrl: json['storage_url'] as String? ?? '',
      status: KycStatus.fromString(
          json['status'] as String? ?? 'pending'),
      createdAt:
          DateTime.parse(json['created_at'] as String),
    );
  }
}