
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';
import '../repositories/wallet_repository.dart';

// Infrastructure 
// If supabaseClientProvider is already declared globally in your app,
// remove this declaration and import it from its source file.

final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

// Repository 

final walletRepositoryProvider =
    Provider.autoDispose<WalletRepository>((ref) {
  return WalletRepository(ref.watch(supabaseClientProvider));
});

// Raw data providers 
// View models watch these; screens never watch them directly.

final walletDataProvider =
    FutureProvider.autoDispose<WalletModel>((ref) async {
  return ref.watch(walletRepositoryProvider).fetchWallet();
});

final walletTransactionsDataProvider =
    FutureProvider.autoDispose<List<WalletTransactionModel>>((ref) async {
  return ref.watch(walletRepositoryProvider).fetchTransactionHistory();
});