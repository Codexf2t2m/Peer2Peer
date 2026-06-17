
// UC: Reset Password (Forgot Password)
//
// Architecture
// • ConsumerStatefulWidget — local state: controller only.
// • ref.listen handles ResetPasswordSuccess → pop + snackbar.
// • Inline error replaces snackbar validation.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/app_back_button.dart';
import '../view_models/reset_password_view_model.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends ConsumerState<ResetPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await ref
        .read(resetPasswordViewModelProvider.notifier)
        .submit(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(resetPasswordViewModelProvider, (_, next) {
      if (next is ResetPasswordSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Password reset email sent.')),
        );
        Navigator.of(context).pop();
      }
    });

    final uiState = ref.watch(resetPasswordViewModelProvider);
    final isLoading = uiState.isLoading;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop()
            ? const AppBackButton()
            : null,
        title: const Text('Reset password'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            Text(
              'Forgot your password?',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Enter your email and we\'ll send a reset link.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // Email 
            TextField(
              controller: _emailController,
              enabled: !isLoading,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            // Inline error 
            if (uiState.hasError) ...[
              const SizedBox(height: 10),
              Text(
                uiState.errorMessage ?? '',
                style: const TextStyle(
                    color: Color(0xFFDC2626), fontSize: 13),
              ),
            ],

            const SizedBox(height: 16),

            // Submit 
            FilledButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2),
                    )
                  : const Text('Send reset link'),
            ),
          ],
        ),
      ),
    );
  }
}