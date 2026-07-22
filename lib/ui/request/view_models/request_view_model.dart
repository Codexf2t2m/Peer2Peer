
// Owns the loan request form state and submission command.
//
// The screen is purely a mutation surface — there is no read AsyncValue
// to load.  A single Notifier<RequestUiState> is the right tool:
//   • idle     → form is editable, no error
//   • loading  → submission in flight, inputs disabled
//   • success  → submission complete, screen can pop
//   • error    → submission failed, error shown inline
//
// Use-case coverage (from the use case diagram):
//   UC: Request Community Loan  → requestType == 'community'
//   UC: Request Direct Loan     → requestType == 'direct' + targetLenderId
//
// Form defaults
// ─────────────
// Interest rate and duration are exposed as user-editable fields —
// the original screen hardcoded these, which is removed here.
// Sensible defaults are provided so the form is ready to submit.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/loan_providers.dart';

// ── Form defaults ─────────────────────────────────────────────────────────────

const _defaultInterestRate = 15.0; // %
const _defaultDurationDays = 30;

// ── UI State ──────────────────────────────────────────────────────────────────

/// Every possible state of the request form.
sealed class RequestUiState {
  const RequestUiState();
}

class RequestIdle extends RequestUiState {
  const RequestIdle();
}

class RequestLoading extends RequestUiState {
  const RequestLoading();
}

/// Emitted once after a successful submission.
/// The screen observes this to pop and show a snackbar.
class RequestSuccess extends RequestUiState {
  const RequestSuccess({
    required this.amount,
    required this.requestType,
  });
  final double amount;
  final String requestType;
}

class RequestError extends RequestUiState {
  const RequestError(this.message);
  final String message;
}

// Convenience getters so the screen never needs to cast.
extension RequestUiStateX on RequestUiState {
  bool get isLoading => this is RequestLoading;
  bool get hasError => this is RequestError;
  bool get isSuccess => this is RequestSuccess;

  String? get errorMessage =>
      this is RequestError
          ? (this as RequestError).message
          : null;
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

class RequestViewModel extends AutoDisposeNotifier<RequestUiState> {
  @override
  RequestUiState build() => const RequestIdle();

  /// Validates and submits the loan request.
  ///
  /// Returns true on success so the screen knows to pop.
  Future<bool> submit({
    required double amount,
    required double interestRate,
    required int durationDays,
    required String requestType,
    String? purpose,
    String? targetLenderId,
  }) async {
    // ── Validation ────────────────────────────────────────────────────
    if (amount <= 0) {
      state = const RequestError('Please enter a valid amount.');
      return false;
    }
    if (interestRate < 0 || interestRate > 100) {
      state = const RequestError(
          'Interest rate must be between 0 and 100 %.');
      return false;
    }
    if (durationDays < 1 || durationDays > 365) {
      state = const RequestError(
          'Duration must be between 1 and 365 days.');
      return false;
    }
    if (requestType == 'direct' &&
        (targetLenderId == null || targetLenderId.trim().isEmpty)) {
      state = const RequestError(
          'Please specify a lender for a direct loan request.');
      return false;
    }

    state = const RequestLoading();

    try {
      await ref.read(loanRepositoryProvider).submitLoanRequest(
            amountRequested: amount,
            interestRate: interestRate,
            durationDays: durationDays,
            purpose: purpose?.trim().isEmpty == true
                ? null
                : purpose?.trim(),
            requestType: requestType,
            targetLenderId: targetLenderId?.trim().isEmpty == true
                ? null
                : targetLenderId?.trim(),
          );

      state = RequestSuccess(
        amount: amount,
        requestType: requestType,
      );
      return true;
    } catch (e) {
      state = RequestError(
          e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  void reset() => state = const RequestIdle();
}

// ── Provider ──────────────────────────────────────────────────────────────────

final requestViewModelProvider =
    NotifierProvider.autoDispose<RequestViewModel, RequestUiState>(
  RequestViewModel.new,
);

// ── Form defaults (exposed for widgets) ──────────────────────────────────────

double get defaultInterestRate => _defaultInterestRate;
int get defaultDurationDays => _defaultDurationDays;