import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_routes.dart';
import '../../../data/providers/data_providers.dart';
import '../../../data/providers/session_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    // Give Flutter a frame to paint the splash UI.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final session = ref.read(sessionProvider);

    if (!session.isSignedIn) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      return;
    }

    // If Supabase is enabled, check onboarding step and route accordingly.
    if (session.supabaseEnabled) {
      try {
        final profileRepo = ref.read(profileRepositoryProvider);
        final step = await profileRepo.fetchOnboardingStep();
        if (!mounted) return;
        _routeByStep(step);
      } catch (_) {
        // On error, fail-open to home
        if (mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } else {
      // Demo mode — go straight home
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  void _routeByStep(String step) {
    final route = switch (step) {
      'pending_verification' => AppRoutes.emailVerification,
      'email_verified' => AppRoutes.bankConnect,
      'bank_connected' => AppRoutes.kycUpload,
      'kyc_uploaded' => AppRoutes.creditAssessment,
      _ => AppRoutes.home, // 'credit_assessed' or 'active'
    };
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0038FF),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.currency_exchange, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'PulaPay',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Community-powered lending',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
