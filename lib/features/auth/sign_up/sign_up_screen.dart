import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app_routes.dart';
import '../../../data/providers/session_provider.dart';
import '../../../ui/widgets/app_back_button.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter email and password.')),
      );
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await ref.read(sessionProvider.notifier).signUp(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (!res.signedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res.message ??
                  'Check your email to confirm your account, then log in.',
            ),
          ),
        );
        Navigator.of(context).popUntil(
          (route) => route.settings.name == AppRoutes.login || route.isFirst,
        );
        return;
      }

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account creation failed. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop() ? const AppBackButton() : null,
        title: const Text('Create account'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            Text(
              'Join PulaPay',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text('Create your profile to start.', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
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
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
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
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.newPassword],
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _createAccount,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Account'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? '),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.login),
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
