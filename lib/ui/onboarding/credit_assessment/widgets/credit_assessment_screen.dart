
// UC: Run Credit Assessment — Step 4 (final) of onboarding.
//
// Architecture
// • ConsumerWidget — zero local state.
// • The VM auto-starts the assessment in build() (see
//   CreditAssessmentViewModel.build() using Future.microtask).
//   The original screen's WidgetsBinding.addPostFrameCallback +
//   _started guard is gone — the VM owns the trigger exactly once
//   per provider lifetime (autoDispose handles re-runs on revisit).
// • CreditAnalysingView and CreditResultView are the two visual states.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app_routes.dart';
import '../../widgets/onboarding_step_indicator.dart';
import '../view_models/credit_assessment_view_model.dart';
import 'credit_analysing_view.dart';
import 'credit_result_view.dart';

class CreditAssessmentScreen extends ConsumerWidget {
  const CreditAssessmentScreen({super.key});

  void _goHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState =
        ref.watch(creditAssessmentViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OnboardingStepIndicator(
                  currentStep: 3),
              const SizedBox(height: 40),

              if (uiState is CreditAssessmentComplete)
                CreditResultView(
                  result: uiState.result,
                  onContinue: () => _goHome(context),
                )
              else if (uiState is CreditAssessmentFailed)
                _FailedView(
                  message: uiState.message,
                  onRetry: () => ref
                      .read(
                          creditAssessmentViewModelProvider
                              .notifier)
                      .run(),
                )
              else
                const CreditAnalysingView(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FailedView extends StatelessWidget {
  const _FailedView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: Color(0xFFEF4444), size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF6B7280), fontSize: 14),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}