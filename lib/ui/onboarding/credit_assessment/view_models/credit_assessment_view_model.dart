
// UC: Run Credit Assessment

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/models/credit_assessment_result_model.dart';
import '../../../../../data/providers/onboarding_providers.dart';

// State 

sealed class CreditAssessmentState {
  const CreditAssessmentState();
}

class CreditAssessmentRunning extends CreditAssessmentState {
  const CreditAssessmentRunning();
}

class CreditAssessmentComplete extends CreditAssessmentState {
  const CreditAssessmentComplete(this.result);
  final CreditAssessmentResultModel result;
}

class CreditAssessmentFailed extends CreditAssessmentState {
  const CreditAssessmentFailed(this.message);
  final String message;
}

extension CreditAssessmentStateX on CreditAssessmentState {
  bool get isRunning => this is CreditAssessmentRunning;
  bool get isComplete => this is CreditAssessmentComplete;
  CreditAssessmentResultModel? get result =>
      this is CreditAssessmentComplete
          ? (this as CreditAssessmentComplete).result
          : null;
}

// ViewModel 

class CreditAssessmentViewModel
    extends AutoDisposeNotifier<CreditAssessmentState> {
  @override
  CreditAssessmentState build() {
    // Auto-start on mount — mirrors the original screen's
    // WidgetsBinding.instance.addPostFrameCallback behaviour
    // but the VM owns the trigger, not the widget.
    Future.microtask(run);
    return const CreditAssessmentRunning();
  }

  Future<void> run() async {
    state = const CreditAssessmentRunning();
    try {
      final result = await ref
          .read(onboardingRepositoryProvider)
          .runCreditAssessment();
      state = CreditAssessmentComplete(result);
    } catch (e) {
      state = CreditAssessmentFailed(
          e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

// Provider 

final creditAssessmentViewModelProvider =
    NotifierProvider.autoDispose<CreditAssessmentViewModel,
        CreditAssessmentState>(
  CreditAssessmentViewModel.new,
);