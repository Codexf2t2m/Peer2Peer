// lib/ui/splash/widgets/splash_screen.dart
//
// Architecture
// ────────────
// • ConsumerWidget — zero local state, no StatefulWidget, no initState.
//   The original used initState() to kick off _route(); that trigger
//   now lives in SplashViewModel.build() via Future.microtask.
// • ref.listen reacts to SplashRouted and performs the single
//   pushReplacementNamed call — navigation is a pure side effect,
//   never mixed into build().
// • The visual splash (icon, title, tagline) is unchanged — this is
//   a pure branding screen with no async data of its own to render.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_models/splash_view_model.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(splashViewModelProvider, (_, next) {
      if (next is SplashRouted) {
        Navigator.of(context)
            .pushReplacementNamed(next.route);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0038FF),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.currency_exchange,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                'PulaPay',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Community-powered lending',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: Colors.white
                          .withValues(alpha: 0.8),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}