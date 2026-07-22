import 'package:supabase_flutter/supabase_flutter.dart';

/// Model for a bank connection row.
class BankConnectionModel {
  final String id;
  final String userId;
  final String provider;
  final String? bankName;
  final String? accountIdExternal;
  final String connectionStatus;
  final DateTime connectedAt;
  final DateTime? lastSyncedAt;

  const BankConnectionModel({
    required this.id,
    required this.userId,
    required this.provider,
    this.bankName,
    this.accountIdExternal,
    required this.connectionStatus,
    required this.connectedAt,
    this.lastSyncedAt,
  });

  factory BankConnectionModel.fromJson(Map<String, dynamic> json) {
    return BankConnectionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      provider: json['provider'] as String,
      bankName: json['bank_name'] as String?,
      accountIdExternal: json['account_id_external'] as String?,
      connectionStatus: json['connection_status'] as String? ?? 'active',
      connectedAt: DateTime.parse(json['connected_at'] as String),
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
    );
  }
}

class BankConnectionRepository {
  final SupabaseClient _db;

  BankConnectionRepository(this._db);

  String? get _uid => _db.auth.currentUser?.id;

  /// Creates a new bank connection via the atomic RPC which also advances
  /// the user's onboarding step from `email_verified` → `bank_connected`.
  Future<String> createConnection({
    required String provider,
    required String bankName,
    required String accountIdExternal,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('User must be signed in to connect a bank account.');

    try {
      final result = await _db.rpc('create_bank_connection', params: {
        'p_user_id': uid,
        'p_provider': provider,
        'p_bank_name': bankName,
        'p_account_id_external': accountIdExternal,
      });
      return result as String;
    } on PostgrestException catch (e) {
      throw Exception('Failed to create bank connection: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred while connecting your bank account.');
    }
  }

  /// Returns all bank connections for the current user.
  Future<List<BankConnectionModel>> fetchMyConnections() async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final List<Map<String, dynamic>> data = await _db
          .from('bank_connections')
          .select()
          .eq('user_id', uid)
          .order('connected_at', ascending: false);

      return data.map((row) => BankConnectionModel.fromJson(row)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to load bank connections: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred while loading bank connections.');
    }
  }

  /// Returns only active (non-revoked) connections.
  Future<List<BankConnectionModel>> fetchActiveConnections() async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final List<Map<String, dynamic>> data = await _db
          .from('bank_connections')
          .select()
          .eq('user_id', uid)
          .eq('connection_status', 'active')
          .order('connected_at', ascending: false);

      return data.map((row) => BankConnectionModel.fromJson(row)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to load active bank connections: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred while loading bank connections.');
    }
  }

  /// Revokes a bank connection by setting its status to 'revoked'.
  Future<void> revokeConnection(String connectionId) async {
    final uid = _uid;
    if (uid == null) throw Exception('User must be signed in to revoke a connection.');

    try {
      await _db
          .from('bank_connections')
          .update({'connection_status': 'revoked', 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', connectionId)
          .eq('user_id', uid);
    } on PostgrestException catch (e) {
      throw Exception('Failed to revoke bank connection: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred while revoking the bank connection.');
    }
  }
}
