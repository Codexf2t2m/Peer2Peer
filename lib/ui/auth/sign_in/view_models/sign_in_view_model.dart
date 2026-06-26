
// UC: Login / Sign In
//
// Pure mutation screen — Notifier<LoginUiState>.
// State machine:
//   idle    → form editable
//   loading → sign-in in flight
//   success → navigate to home
//   error   → inline error message

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/providers/session_provider.dart';

// UI State 

sealed class LoginUiState {
  const LoginUiState();
}

class LoginIdle extends LoginUiState {
  const LoginIdle();
}

class LoginLoading extends LoginUiState {
  const LoginLoading();
}

class LoginSuccess extends LoginUiState {
  const LoginSuccess();
}

class LoginError extends LoginUiState {
  const LoginError(this.message);
  final String message;
}

extension LoginUiStateX on LoginUiState {
  bool get isLoading => this is LoginLoading;
  bool get hasError => this is LoginError;
  String? get errorMessage =>
      this is LoginError ? (this as LoginError).message : null;
}

// ViewModel 

class LoginViewModel extends AutoDisposeNotifier<LoginUiState> {
  @override
  LoginUiState build() => const LoginIdle();

  Future<void> submit({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      state = const LoginError('Enter your email and password.');
      return;
    }

    state = const LoginLoading();

    try {
      await ref.read(sessionProvider.notifier).signIn(
            email: email.trim(),
            password: password,
          );
      state = const LoginSuccess();
    } catch (e) {
      state = LoginError(
        e.toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('AuthException: ', ''),
      );
    }
  }

  void reset() => state = const LoginIdle();
}

// Provider 

final loginViewModelProvider =
    NotifierProvider.autoDispose<LoginViewModel, LoginUiState>(
  LoginViewModel.new,
);