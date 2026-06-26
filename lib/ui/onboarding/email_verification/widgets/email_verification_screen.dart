
// UC: Verify Email — Step 1 of onboarding.
//
// Architecture
// • ConsumerWidget — zero local state.
// • Watches emailVerificationViewModelProvider for both the
//   "check verification" and "resend email" commands.
// • ref.listen handles navigation on EmailVerifiedSuccess and
//   shows snackbars for errors/resend success.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app_routes.dart';
import '../../../../../data/providers/session_provider.dart';
import '../../email_verification/view_models/email_verification_view_model.dart'
    show EmailVerificationViewModel, emailVerificationViewModelProvider, EmailVerifiedSuccess, EmailVerificationError, ResendSuccess, ResendError, EmailVerificationStateX;
import '../../widgets/onboarding_step_indicator.dart';

class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(emailVerificationViewModelProvider,
        (_, next) {
      if (next is EmailVerifiedSuccess) {
        Navigator.of(context)
            .pushReplacementNamed(AppRoutes.bankConnect);
      } else if (next is EmailVerificationError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });

    final uiState =
        ref.watch(emailVerificationViewModelProvider);
    final email =
        ref.watch(sessionProvider).currentEmail ??
            'your email';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OnboardingStepIndicator(
                  currentStep: 0),
              const SizedBox(height: 40),

              // Icon 
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF0038FF)
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  color: Color(0xFF0038FF),
                  size: 36,
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Verify your email',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                      height: 1.5),
                  children: [
                    const TextSpan(
                        text:
                            'We sent a verification link to '),
                    TextSpan(
                      text: email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const TextSpan(
                      text:
                          '. Open your inbox and tap the link, then come back here.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Tips card 
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151)),
                    ),
                    SizedBox(height: 8),
                    _Tip(
                        text:
                            'Check your spam or junk folder.'),
                    _Tip(
                        text:
                            'The link expires after 24 hours.'),
                    _Tip(
                        text:
                            'Add no-reply@supabase.com to your contacts.'),
                  ],
                ),
              ),

              if (uiState is ResendSuccess) ...[
                const SizedBox(height: 16),
                Text(
                  uiState.message,
                  style: const TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (uiState is ResendError) ...[
                const SizedBox(height: 16),
                Text(
                  uiState.message,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const Spacer(),

              // Primary CTA 
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: uiState.isLoading
                      ? null
                      : () => ref
                          .read(
                              emailVerificationViewModelProvider
                                  .notifier)
                          .checkVerification(),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF0038FF),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: uiState.isCheckLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "I've verified my email",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Resend 
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: uiState.isLoading
                      ? null
                      : () => ref
                          .read(
                              emailVerificationViewModelProvider
                                  .notifier)
                          .resendEmail(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: uiState.isResendLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                                  strokeWidth: 2),
                        )
                      : const Text('Resend email'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(
                  color: Color(0xFF6B7280))),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}