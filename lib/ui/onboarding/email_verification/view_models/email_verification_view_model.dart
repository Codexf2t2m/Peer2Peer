
// UC: Verify Email
//
// Two commands on one notifier:
//   checkVerification() → on success, state = EmailVerifiedSuccess
//   resendEmail()       → on success, state = ResendSuccess(message)

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/providers/onboarding_providers.dart';
import '../../../../../data/providers/session_provider.dart';

// State 

sealed class EmailVerificationState {
  const EmailVerificationState();
}

class EmailVerificationIdle extends EmailVerificationState {
  const EmailVerificationIdle();
}

class EmailVerificationLoading extends EmailVerificationState {
  const EmailVerificationLoading();
}

class EmailVerifiedSuccess extends EmailVerificationState {
  const EmailVerifiedSuccess();
}

class EmailVerificationError extends EmailVerificationState {
  const EmailVerificationError(this.message);
  final String message;
}

class ResendLoading extends EmailVerificationState {
  const ResendLoading();
}

class ResendSuccess extends EmailVerificationState {
  const ResendSuccess(this.message);
  final String message;
}

class ResendError extends EmailVerificationState {
  const ResendError(this.message);
  final String message;
}

extension EmailVerificationStateX on EmailVerificationState {
  bool get isCheckLoading => this is EmailVerificationLoading;
  bool get isResendLoading => this is ResendLoading;
  bool get isLoading =>
      this is EmailVerificationLoading || this is ResendLoading;
  bool get isSuccess => this is EmailVerifiedSuccess;
}

// ViewModel 

class EmailVerificationViewModel
    extends AutoDisposeNotifier<EmailVerificationState> {
  @override
  EmailVerificationState build() =>
      const EmailVerificationIdle();

  Future<bool> checkVerification() async {
    state = const EmailVerificationLoading();
    try {
      final verified = await ref
          .read(onboardingRepositoryProvider)
          .confirmEmailVerified();

      if (verified) {
        state = const EmailVerifiedSuccess();
        return true;
      } else {
        state = const EmailVerificationError(
            'Email not confirmed yet. Check your inbox and try again.');
        return false;
      }
    } catch (e) {
      state = EmailVerificationError(
          e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<void> resendEmail() async {
    final email = ref.read(sessionProvider).currentEmail;
    if (email == null) return;

    state = const ResendLoading();
    try {
      await ref
          .read(onboardingRepositoryProvider)
          .resendVerificationEmail(email);
      state = ResendSuccess(
          'Verification email resent to $email.');
    } catch (e) {
      state = ResendError(
          e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void reset() => state = const EmailVerificationIdle();
}

// Provider 

final emailVerificationViewModelProvider = NotifierProvider.autoDispose<
    EmailVerificationViewModel, EmailVerificationState>(
  EmailVerificationViewModel.new,
);