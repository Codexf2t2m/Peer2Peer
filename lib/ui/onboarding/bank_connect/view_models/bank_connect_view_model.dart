
// UC: Connect Bank Account

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/providers/onboarding_providers.dart';

// Bank option data class 

class BankOption {
  const BankOption({
    required this.name,
    required this.code,
    required this.logo,
  });

  final String name;
  final String code;
  final String logo;
}

const bankOptions = [
  BankOption(name: 'First National Bank', code: 'FNB', logo: '🏦'),
  BankOption(name: 'Standard Bank', code: 'StandardBank', logo: '🏛️'),
  BankOption(name: 'Stanbic Bank', code: 'Stanbic', logo: '🏢'),
  BankOption(name: 'Absa Botswana', code: 'Absa', logo: '🏧'),
  BankOption(name: 'Orange Money', code: 'OrangeMoney', logo: '📱'),
  BankOption(name: 'Mascom MyZaka', code: 'Mascom', logo: '📲'),
];

// State 

sealed class BankConnectState {
  const BankConnectState();
}

class BankConnectIdle extends BankConnectState {
  const BankConnectIdle();
}

class BankConnectLoading extends BankConnectState {
  const BankConnectLoading(this.bankName);
  final String bankName;
}

class BankConnectSuccess extends BankConnectState {
  const BankConnectSuccess(this.bankName);
  final String bankName;
}

class BankConnectError extends BankConnectState {
  const BankConnectError(this.message);
  final String message;
}

extension BankConnectStateX on BankConnectState {
  bool get isLoading => this is BankConnectLoading;
  bool get isSuccess => this is BankConnectSuccess;
  String? get errorMessage => this is BankConnectError
      ? (this as BankConnectError).message
      : null;
}

// ViewModel 

class BankConnectViewModel
    extends AutoDisposeNotifier<BankConnectState> {
  @override
  BankConnectState build() => const BankConnectIdle();

  Future<bool> connect(BankOption bank) async {
    state = BankConnectLoading(bank.name);
    try {
      // Simulate Stitch OAuth delay.
      // In production: launch OAuth URL, await callback.
      await Future<void>.delayed(
          const Duration(milliseconds: 1500));

      await ref
          .read(onboardingRepositoryProvider)
          .connectBank(
            provider: 'stitch',
            bankName: bank.name,
            accountIdExternal:
                'mock-${bank.code}-${DateTime.now().millisecondsSinceEpoch}',
          );

      state = BankConnectSuccess(bank.name);
      return true;
    } catch (e) {
      state = BankConnectError(
          e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  void reset() => state = const BankConnectIdle();
}

// Provider 

final bankConnectViewModelProvider = NotifierProvider.autoDispose<
    BankConnectViewModel, BankConnectState>(
  BankConnectViewModel.new,
);