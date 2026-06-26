import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  // 1. Pass the client via constructor instead of a hardcoded singleton instance
  final SupabaseClient _db;

  TransactionRepository(this._db);

  String? get _uid => _db.auth.currentUser?.id;

  /// Fetches the most recent [limit] transactions for the current user.
  Future<List<TransactionModel>> fetchMyTransactions({int limit = 50}) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception('User must be logged in to fetch transactions.');
    }

    try {
      final List<Map<String, dynamic>> data = await _db
          .from('transactions')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(limit);

      // Safe mapping without manual runtime array casting
      return data.map((row) => TransactionModel.fromJson(row)).toList();
    } on PostgrestException catch (e) {
      // 2. Wrap queries in try/catch to protect your UI layer from crashing
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected network error occurred.');
    }
  }

  /// Inserts a transaction into the database.
  /// Business rules (fees, statuses) are passed down instead of hardcoded.
  Future<TransactionModel> insertTransaction({
    required double amount,
    required String type,
    double fee = 0.0,
    String status = 'pending',
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception('User must be logged in to create transactions.');
    }

    try {
      final Map<String, dynamic> data = await _db
          .from('transactions')
          .insert({
            'user_id': uid,
            'type': type,
            'gross_amount': amount,
            'fee_amount': fee,
            'net_amount': amount - fee,
            'status': status,
          })
          .select()
          .single();

      return TransactionModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw Exception('Failed to create transaction: ${e.message}');
    } catch (e) {
      throw Exception('Network communication failure.');
    }
  }
}
