
// UC: Register Account + Verify Email
//
// Architecture
// • ConsumerStatefulWidget — local state is only:
//     _emailController, _passwordController, _confirmController
//     _obscure (password visibility toggle — pure widget concern)
//
// • ref.listen handles navigation side-effects:
//     SignUpSuccess          → pushNamedAndRemoveUntil to home
//     SignUpAwaitingEmail... → popUntil login + show snackbar
//   This keeps build() a pure render function.
//
// • Inline field errors replace ScaffoldMessenger snackbars for
//   validation — snackbars are reserved for navigation-level events.
//
// • No Supabase imports, no AuthException, no session provider.
//   All of that is behind SignUpViewModel.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app_routes.dart';
import '../../../widgets/app_back_button.dart';
import '../view_models/sign_up_view_model.dart';
import '../../widgets/password_strength_bar.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState
    extends ConsumerState<CreateAccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscure = true;

  // Rebuilds the strength bar as the user types — local setState is
  // appropriate here since this is purely visual, not a VM concern.
  String _passwordValue = '';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() => _passwordValue = _passwordController.text);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await ref.read(signUpViewModelProvider.notifier).submit(
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Side-effect listener 
    ref.listen(signUpViewModelProvider, (_, next) {
      if (next is SignUpSuccess) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
        return;
      }
      if (next is SignUpAwaitingEmailConfirmation) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
        Navigator.of(context).popUntil(
          (route) =>
              route.settings.name == AppRoutes.login ||
              route.isFirst,
        );
      }
    });

    final uiState = ref.watch(signUpViewModelProvider);
    final isLoading = uiState.isLoading;
    final errorMessage = uiState.errorMessage;

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop()
            ? const AppBackButton()
            : null,
        title: const Text('Create account'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),

            // Header 
            Text(
              'Join PulaPay',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Create your profile to start.',
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // Email 
            TextField(
              controller: _emailController,
              enabled: !isLoading,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [
                AutofillHints.newUsername,
                AutofillHints.email,
              ],
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Password 
            TextField(
              controller: _passwordController,
              enabled: !isLoading,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscure = !_obscure),
                  icon: HugeIcon(
                    icon: _obscure
                        ? HugeIcons.strokeRoundedView
                        : HugeIcons.strokeRoundedViewOff,
                    color: Theme.of(context).iconTheme.color,
                    size: 22,
                  ),
                ),
              ),
            ),

            // Password strength bar — shown as user types
            PasswordStrengthBar(password: _passwordValue),

            const SizedBox(height: 12),

            // Confirm password 
            TextField(
              controller: _confirmController,
              enabled: !isLoading,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.newPassword],
              decoration: const InputDecoration(
                labelText: 'Confirm password',
                border: OutlineInputBorder(),
              ),
            ),

            // Inline error 
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                errorMessage,
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 13,
                ),
              ),
            ],

            const SizedBox(height: 20),

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
                  : const Text('Create Account'),
            ),

            const SizedBox(height: 16),

            // Login link 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? '),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(context)
                          .pushNamed(AppRoutes.login),
                  child: const Text('Login'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}