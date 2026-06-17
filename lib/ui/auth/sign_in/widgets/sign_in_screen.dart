
// UC: Login / Sign In
//
// Architecture
// • ConsumerStatefulWidget — local state: controllers + _obscure only.
// • ref.listen handles LoginSuccess → navigate home.
// • No Supabase imports, no AuthException, no setState for loading.
// • Inline error replaces snackbar validation.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app_routes.dart';
import '../../../widgets/app_back_button.dart';
import '../view_models/sign_in_view_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await ref.read(loginViewModelProvider.notifier).submit(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(loginViewModelProvider, (_, next) {
      if (next is LoginSuccess) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      }
    });

    final uiState = ref.watch(loginViewModelProvider);
    final isLoading = uiState.isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop()
            ? const AppBackButton()
            : null,
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            Text(
              'Welcome back',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text('Log in to continue.',
                style: theme.textTheme.bodyMedium),

            const SizedBox(height: 24),

            // Email 
            TextField(
              controller: _emailController,
              enabled: !isLoading,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [
                AutofillHints.username,
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
              autofillHints: const [AutofillHints.password],
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
                  : const Text('Login'),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: isLoading
                  ? null
                  : () => Navigator.of(context)
                      .pushNamed(AppRoutes.resetPassword),
              child: const Text('Forgot password?'),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(context)
                          .pushNamed(AppRoutes.createAccount),
                  child: const Text('Create one'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}