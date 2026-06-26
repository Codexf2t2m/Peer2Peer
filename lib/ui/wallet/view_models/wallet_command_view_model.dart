
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/wallet_providers.dart';
import 'wallet_view_model.dart';

// State 

sealed class WalletCommandState {
  const WalletCommandState();
}

class WalletCommandIdle extends WalletCommandState {
  const WalletCommandIdle();
}

class WalletCommandLoading extends WalletCommandState {
  const WalletCommandLoading();
}

class WalletCommandSuccess extends WalletCommandState {
  const WalletCommandSuccess(this.message);
  final String message;
}

class WalletCommandError extends WalletCommandState {
  const WalletCommandError(this.message);
  final String message;
}

// Convenience getters so dialogs don't need to cast.
extension WalletCommandStateX on WalletCommandState {
  bool get isLoading => this is WalletCommandLoading;
  bool get hasError => this is WalletCommandError;
  String? get errorMessage =>
      this is WalletCommandError ? (this as WalletCommandError).message : null;
}

// ViewModel 

class WalletCommandViewModel
    extends AutoDisposeNotifier<WalletCommandState> {
  @override
  WalletCommandState build() => const WalletCommandIdle();

  /// Tops up the wallet by [amount] BWP.
  ///
  /// Returns true on success so the dialog can close itself.
  Future<bool> topUp(double amount) async {
    state = const WalletCommandLoading();
    try {
      await ref.read(walletRepositoryProvider).topUp(amount);
      state = WalletCommandSuccess(
          'Wallet topped up successfully.');
      // Refresh the read VM without a full loading spinner.
      ref
          .read(walletViewModelProvider.notifier)
          .silentRefresh();
      return true;
    } catch (e) {
      state = WalletCommandError(
          e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  /// Transfers [amount] BWP to [recipient].
  ///
  /// Returns true on success so the dialog can close itself.
  Future<bool> transfer(double amount, String recipient) async {
    state = const WalletCommandLoading();
    try {
      await ref
          .read(walletRepositoryProvider)
          .transfer(amount, recipient);
      state = WalletCommandSuccess('Transfer successful.');
      ref
          .read(walletViewModelProvider.notifier)
          .silentRefresh();
      return true;
    } catch (e) {
      state = WalletCommandError(
          e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  void reset() => state = const WalletCommandIdle();
}

// Provider 

final walletCommandViewModelProvider = NotifierProvider.autoDispose<
    WalletCommandViewModel, WalletCommandState>(
  WalletCommandViewModel.new,
);