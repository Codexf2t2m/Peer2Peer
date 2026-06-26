
// Single data boundary for the Wallet feature.
//
// Reads:
//   PROFILES          → wallet balance + limits
//   TRANSACTIONS      → full wallet history (all types)
//   BANK_CONNECTIONS  → linked bank accounts
//
// Writes:
//   top-up   → calls 'wallet_top_up' RPC
//   transfer → calls 'wallet_transfer' RPC

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/bank_connection_model.dart';
import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';

class WalletRepository {
  WalletRepository(this._db);

  final SupabaseClient _db;

  String? get _uid => _db.auth.currentUser?.id;

  // Balance 

  /// Returns the current user's wallet balance from PROFILES.
  Future<WalletModel> fetchWallet() async {
    final uid = _uid;
    if (uid == null) return WalletModel.empty;

    try {
      final data = await _db
          .from('profiles')
          .select(
            'id, available_lending_amount, borrowing_limit',
          )
          .eq('id', uid)
          .single();

      return WalletModel.fromJson(Map<String, dynamic>.from(data));
    } on PostgrestException catch (e) {
      throw Exception('Failed to load wallet: ${e.message}');
    } catch (e) {
      throw Exception(
          'An unexpected error occurred while loading your wallet.');
    }
  }

  // Transaction history 

  /// Returns all transactions for the current user, newest first.
  /// Joins loan purpose and counterparty name where available.
  Future<List<WalletTransactionModel>> fetchTransactionHistory() async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final data = await _db
          .from('transactions')
          .select(
            'id, user_id, type, gross_amount, fee_amount, net_amount, '
            'status, created_at, loan_request_id, active_loan_id, '
            'loan_requests(purpose, profiles!borrower_id(full_name))',
          )
          .eq('user_id', uid)
          .order('created_at', ascending: false);

      return (data as List)
          .map((row) => WalletTransactionModel.fromJson(
              Map<String, dynamic>.from(row as Map)))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(
          'Failed to load transaction history: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    }
  }

  // Bank connections 

  /// Returns all bank accounts linked by the current user.
  Future<List<BankConnectionModel>> fetchBankConnections() async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final data = await _db
          .from('bank_connections')
          .select()
          .eq('user_id', uid)
          .order('connected_at', ascending: false);

      return (data as List)
          .map((row) => BankConnectionModel.fromJson(
              Map<String, dynamic>.from(row as Map)))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(
          'Failed to load bank connections: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    }
  }

  // Mutations 

  /// Tops up the wallet by [amount] BWP via the `wallet_top_up` RPC.
  ///
  /// Returns the updated [WalletModel] on success.
  Future<WalletModel> topUp(double amount) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception('You must be signed in to top up.');
    }
    if (amount <= 0) {
      throw Exception('Please enter an amount greater than zero.');
    }

    try {
      await _db.rpc('wallet_top_up', params: {
        'p_user_id': uid,
        'p_amount': amount,
      });

      // Re-fetch the updated balance.
      return fetchWallet();
    } on PostgrestException catch (e) {
      throw Exception('Top-up failed: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred during top-up.');
    }
  }

  /// Transfers [amount] BWP to [recipientIdentifier] (name or phone number)
  /// via the `wallet_transfer` RPC.
  ///
  /// Returns the updated [WalletModel] on success.
  Future<WalletModel> transfer(
    double amount,
    String recipientIdentifier,
  ) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception('You must be signed in to transfer funds.');
    }
    if (amount <= 0) {
      throw Exception('Please enter an amount greater than zero.');
    }
    if (recipientIdentifier.trim().isEmpty) {
      throw Exception('Please enter a recipient name or number.');
    }

    try {
      await _db.rpc('wallet_transfer', params: {
        'p_sender_id': uid,
        'p_recipient_identifier': recipientIdentifier.trim(),
        'p_amount': amount,
      });

      return fetchWallet();
    } on PostgrestException catch (e) {
      throw Exception('Transfer failed: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
          'An unexpected error occurred during transfer.');
    }
  }
}