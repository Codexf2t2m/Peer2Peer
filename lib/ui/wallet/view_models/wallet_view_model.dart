
// Read-side view model for the Wallet screen.
//
// Owns:
//   • WalletUiState — balance + recent transactions shaped for the screen
//   • refresh()     — wired to RefreshIndicator
//
// Mutation commands (top-up, transfer) live in WalletCommandViewModel


import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/wallet_model.dart';
import '../../../data/models/wallet_transaction_model.dart';
import '../../../data/providers/wallet_providers.dart';

// UI State 

/// Immutable snapshot of everything WalletScreen needs to render.
class WalletUiState {
  const WalletUiState({
    required this.wallet,
    required this.transactions,
  });

  final WalletModel wallet;

  /// Full transaction history for the History bottom sheet.
  final List<WalletTransactionModel> transactions;

  bool get hasTransactions => transactions.isNotEmpty;
}

// ViewModel 

class WalletViewModel extends AutoDisposeAsyncNotifier<WalletUiState> {
  @override
  Future<WalletUiState> build() => _load();

  Future<WalletUiState> _load() async {
    final repo = ref.watch(walletRepositoryProvider);

    final results = await Future.wait([
      repo.fetchWallet(),
      repo.fetchTransactionHistory(),
    ]);

    return WalletUiState(
      wallet: results[0] as WalletModel,
      transactions: results[1] as List<WalletTransactionModel>,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  /// Called after a successful mutation to refresh the balance and history
  /// without a full loading spinner — keeps the UI responsive.
  Future<void> silentRefresh() async {
    final next = await AsyncValue.guard(_load);
    state = next;
  }
}

// Provider 

final walletViewModelProvider =
    AsyncNotifierProvider.autoDispose<WalletViewModel, WalletUiState>(
  WalletViewModel.new,
);