
// Owns the sign-up form submission command.
//
// UC: Register Account + Verify Email
//
// State machine:
//   idle          → form editable, no error
//   loading       → sign-up in flight, inputs disabled
//   awaitingEmail → Supabase sent a confirmation email; screen should
//                   redirect to login with an informational message
//   success       → signed in immediately (e.g. email confirm disabled
//                   in Supabase project settings); screen navigates home
//   error         → submission failed; message shown inline
//
// Validation lives here, not in the widget, so it can be unit-tested
// without a BuildContext.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/providers/session_provider.dart';

// UI State 

sealed class SignUpUiState {
  const SignUpUiState();
}

class SignUpIdle extends SignUpUiState {
  const SignUpIdle();
}

class SignUpLoading extends SignUpUiState {
  const SignUpLoading();
}

/// Supabase returned successfully but email confirmation is required.
/// The screen should navigate to login and show [message].
class SignUpAwaitingEmailConfirmation extends SignUpUiState {
  const SignUpAwaitingEmailConfirmation(this.message);
  final String message;
}

/// Signed in immediately — navigate to home.
class SignUpSuccess extends SignUpUiState {
  const SignUpSuccess();
}

class SignUpError extends SignUpUiState {
  const SignUpError(this.message);
  final String message;
}

extension SignUpUiStateX on SignUpUiState {
  bool get isLoading => this is SignUpLoading;
  bool get hasError => this is SignUpError;
  String? get errorMessage =>
      this is SignUpError ? (this as SignUpError).message : null;
}

// Validation helpers 

/// Returns null when valid, an error string when invalid.
String? validateEmail(String email) {
  if (email.trim().isEmpty) return 'Email is required.';
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailRegex.hasMatch(email.trim())) {
    return 'Enter a valid email address.';
  }
  return null;
}

String? validatePassword(String password) {
  if (password.isEmpty) return 'Password is required.';
  if (password.length < 8) return 'Password must be at least 8 characters.';
  return null;
}

String? validateConfirmPassword(String password, String confirm) {
  if (confirm.isEmpty) return 'Please confirm your password.';
  if (password != confirm) return 'Passwords do not match.';
  return null;
}

/// Returns a 0–4 strength score for the password strength indicator.
int passwordStrength(String password) {
  if (password.isEmpty) return 0;
  int score = 0;
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
  return score.clamp(0, 4);
}

// ViewModel 

class SignUpViewModel extends AutoDisposeNotifier<SignUpUiState> {
  @override
  SignUpUiState build() => const SignUpIdle();

  Future<void> submit({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // Inline validation 
    final emailError = validateEmail(email);
    if (emailError != null) {
      state = SignUpError(emailError);
      return;
    }
    final passwordError = validatePassword(password);
    if (passwordError != null) {
      state = SignUpError(passwordError);
      return;
    }
    final confirmError =
        validateConfirmPassword(password, confirmPassword);
    if (confirmError != null) {
      state = SignUpError(confirmError);
      return;
    }

    state = const SignUpLoading();

    try {
      // Delegates to the existing session notifier — the VM never
      // imports Supabase directly.
      final result = await ref
          .read(sessionProvider.notifier)
          .signUp(email: email.trim(), password: password);

      if (!result.signedIn) {
        // Supabase requires email confirmation before the session is active.
        state = SignUpAwaitingEmailConfirmation(
          result.message ??
              'Check your email to confirm your account, then log in.',
        );
        return;
      }

      state = const SignUpSuccess();
    } catch (e) {
      // AuthException and generic errors are both caught here —
      // the widget never sees Supabase types.
      state = SignUpError(
        e.toString().replaceFirst('Exception: ', '').replaceFirst('AuthException: ', ''),
      );
    }
  }

  void reset() => state = const SignUpIdle();
}

// Provider 

final signUpViewModelProvider =
    NotifierProvider.autoDispose<SignUpViewModel, SignUpUiState>(
  SignUpViewModel.new,
);