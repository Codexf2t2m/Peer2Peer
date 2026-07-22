
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/borrower_profile_model.dart';
import '../../../../data/providers/community_fund_providers.dart';

// Read UI State 

class CommunityFundUiState {
  const CommunityFundUiState({
    required this.profile,
    required this.walletBalance,
  });

  final BorrowerProfileModel profile;
  final double walletBalance;
}

// Read ViewModel 

class CommunityFundViewModel
    extends AutoDisposeFamilyAsyncNotifier<CommunityFundUiState, String> {
  @override
  Future<CommunityFundUiState> build(String arg) => _load(arg);

  Future<CommunityFundUiState> _load(String loanRequestId) async {
    final repo = ref.watch(communityFundRepositoryProvider);

    final profile = await repo.fetchBorrowerProfile(loanRequestId);
    final walletBalance = await repo.fetchWalletBalance();

    return CommunityFundUiState(
      profile: profile,
      walletBalance: walletBalance,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(arg));
  }

  Future<void> silentRefresh() async {
    final next = await AsyncValue.guard(() => _load(arg));
    state = next;
  }
}

// Read Provider 

final communityFundViewModelProvider =
    AsyncNotifierProvider.autoDispose.family<CommunityFundViewModel,
        CommunityFundUiState, String>(
  CommunityFundViewModel.new,
);

// Fund Command State 

sealed class FundCommandState {
  const FundCommandState();
}

class FundCommandIdle extends FundCommandState {
  const FundCommandIdle();
}

class FundCommandLoading extends FundCommandState {
  const FundCommandLoading();
}

class FundCommandSuccess extends FundCommandState {
  const FundCommandSuccess({required this.amount});
  final double amount;
}

class FundCommandError extends FundCommandState {
  const FundCommandError(this.message);
  final String message;
}

extension FundCommandStateX on FundCommandState {
  bool get isLoading => this is FundCommandLoading;
  bool get hasError => this is FundCommandError;
  String? get errorMessage =>
      this is FundCommandError
          ? (this as FundCommandError).message
          : null;
}

// Fund Command ViewModel 

class CommunityFundCommandViewModel
    extends AutoDisposeNotifier<FundCommandState> {
  @override
  FundCommandState build() => const FundCommandIdle();

  Future<bool> fund({
    required String loanRequestId,
    required double amount,
  }) async {
    state = const FundCommandLoading();

    try {
      await ref
          .read(communityFundRepositoryProvider)
          .fundLoan(loanRequestId: loanRequestId, amount: amount);

      state = FundCommandSuccess(amount: amount);

      ref
          .read(communityFundViewModelProvider(loanRequestId).notifier)
          .silentRefresh();

      return true;
    } catch (e) {
      state = FundCommandError(
          e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  void reset() => state = const FundCommandIdle();
}

// Fund Command Provider 

final communityFundCommandViewModelProvider =
    NotifierProvider.autoDispose<CommunityFundCommandViewModel,
        FundCommandState>(
  CommunityFundCommandViewModel.new,
);