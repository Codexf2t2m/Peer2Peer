import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app_routes.dart';
import '../../../data/providers/data_providers.dart';
import '../../../data/providers/session_provider.dart';
import '../../../data/providers/supabase_providers.dart';

/// Step 1 of onboarding: email verification gate.
///
/// Shown after sign-up when `onboarding_step = 'pending_verification'`.
/// The user is asked to check their inbox and tap "I've verified my email".
/// The app refreshes the session and checks `email_confirmed_at`.
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _resending = false;
  String? _resendMessage;

  Future<void> _resendEmail() async {
    setState(() {
      _resending = true;
      _resendMessage = null;
    });

    try {
      final session = ref.read(sessionProvider);
      final email = session.currentEmail;
      if (email != null && session.supabaseEnabled) {
        await ref
            .read(supabaseClientProvider)
            .auth
            .resend(type: OtpType.signup, email: email);
        if (mounted) {
          setState(() => _resendMessage = 'Verification email resent to $email.');
        }
      } else {
        if (mounted) setState(() => _resendMessage = 'Email resent.');
      }
    } catch (_) {
      if (mounted) setState(() => _resendMessage = 'Could not resend email. Please try again.');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _checkVerification() async {
    final controller = ref.read(onboardingControllerProvider.notifier);
    final success = await controller.confirmEmailVerified();
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.bankConnect);
    } else {
      final state = ref.read(onboardingControllerProvider);
      final message = state.asError?.error.toString().replaceFirst('Exception: ', '') ??
          'Email not confirmed yet.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final email = session.currentEmail ?? 'your email';
    final isLoading = ref.watch(onboardingControllerProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step indicator
              const OnboardingStepIndicator(currentStep: 0),
              const SizedBox(height: 40),

              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF0038FF).withValues(alpha: 0.08),
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
                  style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280), height: 1.5),
                  children: [
                    const TextSpan(text: 'We sent a verification link to '),
                    TextSpan(
                      text: email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const TextSpan(
                      text: '. Open your inbox and tap the link, then come back here.',
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
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tips',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF374151)),
                    ),
                    const SizedBox(height: 8),
                    _buildTip('Check your spam or junk folder.'),
                    _buildTip('The link expires after 24 hours.'),
                    _buildTip('Add no-reply@supabase.com to your contacts.'),
                  ],
                ),
              ),

              if (_resendMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _resendMessage!,
                  style: const TextStyle(
                    color: Color(0xFF059669),
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
                  onPressed: isLoading ? null : _checkVerification,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0038FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          "I've verified my email",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Secondary: Resend
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _resending ? null : _resendEmail,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _resending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
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

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF6B7280))),
          Expanded(
            child: Text(text, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ── Shared step indicator ─────────────────────────────────────────────────────

class OnboardingStepIndicator extends StatelessWidget {
  const OnboardingStepIndicator({required this.currentStep});

  final int currentStep;

  static const _labels = ['Email', 'Bank', 'ID', 'Credit'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: i ~/ 2 < currentStep
                  ? const Color(0xFF0038FF)
                  : const Color(0xFFE5E7EB),
            ),
          );
        }
        final step = i ~/ 2;
        final done = step < currentStep;
        final active = step == currentStep;

        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done || active ? const Color(0xFF0038FF) : const Color(0xFFE5E7EB),
              ),
              child: Icon(
                done ? Icons.check : Icons.circle,
                size: done ? 16 : 8,
                color: done || active ? Colors.white : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _labels[step],
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? const Color(0xFF0038FF) : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        );
      }),
    );
  }
}
