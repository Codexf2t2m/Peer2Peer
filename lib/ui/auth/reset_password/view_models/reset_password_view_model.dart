
// UC: Reset Password (Forgot Password flow)
//
// State machine:
//   idle    → form editable
//   loading → reset email in flight
//   success → email sent; screen pops with snackbar
//   error   → inline error message

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/providers/session_provider.dart';

// UI State 

sealed class ResetPasswordUiState {
  const ResetPasswordUiState();
}

class ResetPasswordIdle extends ResetPasswordUiState {
  const ResetPasswordIdle();
}

class ResetPasswordLoading extends ResetPasswordUiState {
  const ResetPasswordLoading();
}

class ResetPasswordSuccess extends ResetPasswordUiState {
  const ResetPasswordSuccess();
}

class ResetPasswordError extends ResetPasswordUiState {
  const ResetPasswordError(this.message);
  final String message;
}

extension ResetPasswordUiStateX on ResetPasswordUiState {
  bool get isLoading => this is ResetPasswordLoading;
  bool get isSuccess => this is ResetPasswordSuccess;
  bool get hasError => this is ResetPasswordError;
  String? get errorMessage =>
      this is ResetPasswordError
          ? (this as ResetPasswordError).message
          : null;
}

// ViewModel 

class ResetPasswordViewModel
    extends AutoDisposeNotifier<ResetPasswordUiState> {
  @override
  ResetPasswordUiState build() => const ResetPasswordIdle();

  Future<void> submit(String email) async {
    if (email.trim().isEmpty) {
      state = const ResetPasswordError('Enter your email address.');
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email.trim())) {
      state = const ResetPasswordError(
          'Enter a valid email address.');
      return;
    }

    state = const ResetPasswordLoading();

    try {
      await ref
          .read(sessionProvider.notifier)
          .sendPasswordReset(email.trim());
      state = const ResetPasswordSuccess();
    } catch (e) {
      state = ResetPasswordError(
        e.toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('AuthException: ', ''),
      );
    }
  }

  void reset() => state = const ResetPasswordIdle();
}

// Provider 

final resetPasswordViewModelProvider = NotifierProvider.autoDispose<
    ResetPasswordViewModel, ResetPasswordUiState>(
  ResetPasswordViewModel.new,
);