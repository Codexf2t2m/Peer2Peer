// lib/ui/splash/view_models/splash_view_model.dart
//
// Determines where the app should route on launch.
//
// Routing logic (unchanged from the original screen, now centralised):
//   1. Not signed in              → login
//   2. Signed in, Supabase off    → home (demo mode)
//   3. Signed in, Supabase on     → look up onboarding_step, route by step
//   4. Step lookup fails          → fail open to home
//
// The VM never touches Navigator — it only exposes a target route string.
// The screen's ref.listen does the actual navigation, keeping this VM
// trivially testable (assert on the emitted route, no widget tree needed).

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app_routes.dart';
import '../../../../data/providers/onboarding_providers.dart';
import '../../../../data/providers/session_provider.dart';

// ── State ─────────────────────────────────────────────────────────────────────

sealed class SplashState {
  const SplashState();
}

/// Still deciding — splash UI stays visible.
class SplashDeciding extends SplashState {
  const SplashDeciding();
}

/// Decision made — screen should navigate to [route].
class SplashRouted extends SplashState {
  const SplashRouted(this.route);
  final String route;
}

// ── Onboarding step → route mapping ───────────────────────────────────────────
//
// Single source of truth for step → route, shared conceptually with
// OnboardingRepository's advance_onboarding_step calls. If a step name
// changes on the backend, update it here only.

String _routeForStep(String step) {
  return switch (step) {
    'pending_verification' => AppRoutes.emailVerification,
    'email_verified' => AppRoutes.bankConnect,
    'bank_connected' => AppRoutes.kycUpload,
    'kyc_uploaded' => AppRoutes.creditAssessment,
    _ => AppRoutes.home, // 'active' or any future terminal step
  };
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

class SplashViewModel extends AutoDisposeNotifier<SplashState> {
  @override
  SplashState build() {
    Future.microtask(_decide);
    return const SplashDeciding();
  }

  Future<void> _decide() async {
    // Give Flutter a frame to paint the splash UI before any navigation.
    await Future<void>.delayed(
        const Duration(milliseconds: 400));

    final session = ref.read(sessionProvider);

    if (!session.isSignedIn) {
      state = const SplashRouted(AppRoutes.login);
      return;
    }

    if (!session.supabaseEnabled) {
      // Demo mode — go straight home.
      state = const SplashRouted(AppRoutes.home);
      return;
    }

    try {
      final step = await ref
          .read(onboardingRepositoryProvider)
          .fetchOnboardingStep();
      state = SplashRouted(_routeForStep(step));
    } catch (_) {
      // Fail open to home rather than stranding the user on splash.
      state = const SplashRouted(AppRoutes.home);
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final splashViewModelProvider =
    AutoDisposeNotifierProvider<SplashViewModel, SplashState>(
  SplashViewModel.new,
);