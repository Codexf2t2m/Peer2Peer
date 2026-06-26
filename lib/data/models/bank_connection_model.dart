
// Maps to the BANK_CONNECTIONS table.
// Used by the "Connect Bank Account" use case visible in the use case diagram.
//
// ERD columns:
//   id, user_id, provider, bank_name, account_id_external,
//   connection_status, connected_at, last_synced_at

/// Represents a single linked bank account.
class BankConnectionModel {
  const BankConnectionModel({
    required this.id,
    required this.userId,
    required this.provider,
    required this.bankName,
    required this.accountIdExternal,
    required this.connectionStatus,
    required this.connectedAt,
    this.lastSyncedAt,
  });

  final String id;
  final String userId;

  /// Open banking provider (e.g. 'stitch', 'mono', 'okra').
  final String provider;

  final String bankName;
  final String accountIdExternal;

  /// 'active' | 'disconnected' | 'error'
  final String connectionStatus;

  final DateTime connectedAt;
  final DateTime? lastSyncedAt;

  // Computed 

  bool get isActive => connectionStatus == 'active';

  String get displayName => '$bankName (${accountIdExternal.length > 4
      ? '****${accountIdExternal.substring(accountIdExternal.length - 4)}'
      : accountIdExternal})';

  // Serialisation 

  factory BankConnectionModel.fromJson(Map<String, dynamic> json) {
    return BankConnectionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      provider: json['provider'] as String? ?? '',
      bankName: json['bank_name'] as String? ?? 'Bank',
      accountIdExternal:
          json['account_id_external'] as String? ?? '',
      connectionStatus:
          json['connection_status'] as String? ?? 'active',
      connectedAt:
          DateTime.parse(json['connected_at'] as String),
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankConnectionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}