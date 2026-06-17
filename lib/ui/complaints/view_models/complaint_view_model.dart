
// Owns the complaint form state and submission command.
//
// This is a pure mutation screen — no async data to load on mount.
// A Notifier<ComplaintUiState> is the right tool:
//   idle     → form editable
//   loading  → submission in flight, inputs disabled
//   success  → complaint submitted, screen shows success state
//   error    → submission failed, error shown inline
//
// ComplaintTypeOption
// The _ComplaintType data class from the original screen is promoted to
// a proper domain object here so it's testable and reusable across widgets.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/complaint_model.dart';
import '../../../data/providers/complaint_providers.dart';


// Complaint type options (UI metadata) 

/// Pairs a [ComplaintType] domain value with its display label and icon.
class ComplaintTypeOption {
  const ComplaintTypeOption({
    required this.type,
    required this.label,
    required this.icon,
  });

  final ComplaintType type;
  final String label;
  final IconData icon;
}

/// All selectable complaint types — single source of truth for both
/// the grid widget and the view model.
const complaintTypeOptions = [
  ComplaintTypeOption(
    type: ComplaintType.fraud,
    label: 'Fraud / Scam',
    icon: Icons.warning_amber_outlined,
  ),
  ComplaintTypeOption(
    type: ComplaintType.harassment,
    label: 'Harassment',
    icon: Icons.block_outlined,
  ),
  ComplaintTypeOption(
    type: ComplaintType.nonRepayment,
    label: 'Non-repayment',
    icon: Icons.money_off_outlined,
  ),
  ComplaintTypeOption(
    type: ComplaintType.impersonation,
    label: 'Impersonation',
    icon: Icons.person_off_outlined,
  ),
  ComplaintTypeOption(
    type: ComplaintType.platformBug,
    label: 'App / Platform',
    icon: Icons.bug_report_outlined,
  ),
  ComplaintTypeOption(
    type: ComplaintType.other,
    label: 'Other',
    icon: Icons.more_horiz_outlined,
  ),
];

// UI State 

sealed class ComplaintUiState {
  const ComplaintUiState();
}

class ComplaintIdle extends ComplaintUiState {
  const ComplaintIdle();
}

class ComplaintLoading extends ComplaintUiState {
  const ComplaintLoading();
}

/// Emitted after successful submission — screen switches to success view.
class ComplaintSuccess extends ComplaintUiState {
  const ComplaintSuccess();
}

class ComplaintError extends ComplaintUiState {
  const ComplaintError(this.message);
  final String message;
}

extension ComplaintUiStateX on ComplaintUiState {
  bool get isLoading => this is ComplaintLoading;
  bool get isSuccess => this is ComplaintSuccess;
  bool get hasError => this is ComplaintError;
  String? get errorMessage =>
      this is ComplaintError
          ? (this as ComplaintError).message
          : null;
}

// ViewModel 

class ComplaintViewModel
    extends AutoDisposeNotifier<ComplaintUiState> {
  @override
  ComplaintUiState build() => const ComplaintIdle();

  Future<void> submit({
    required ComplaintType type,
    required String description,
    String? againstUserEmail,
  }) async {
    // Client-side validation before hitting the network.
    if (description.trim().length < 20) {
      state = const ComplaintError(
          'Please provide at least 20 characters.');
      return;
    }

    state = const ComplaintLoading();

    try {
      await ref
          .read(complaintRepositoryProvider)
          .submitComplaint(
            type: type,
            description: description,
            againstUserEmail: againstUserEmail,
          );

      state = const ComplaintSuccess();
    } catch (e) {
      state = ComplaintError(
          e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void reset() => state = const ComplaintIdle();
}

// Provider 

final complaintViewModelProvider = NotifierProvider.autoDispose<
    ComplaintViewModel, ComplaintUiState>(
  ComplaintViewModel.new,
);