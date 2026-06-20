
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/onboarding_repository.dart';

// Remove if already declared globally.
final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final onboardingRepositoryProvider =
    Provider.autoDispose<OnboardingRepository>((ref) {
  return OnboardingRepository(ref.watch(supabaseClientProvider));
});