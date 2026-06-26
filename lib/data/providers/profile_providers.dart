
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile_model.dart';
import '../repositories/profile_repository.dart';

// Remove if supabaseClientProvider is already declared globally.
final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final profileRepositoryProvider =
    Provider.autoDispose<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseClientProvider));
});

/// Raw data provider — watched by the VM only, never directly by the screen.
final profileDataProvider =
    FutureProvider.autoDispose<UserProfileModel>((ref) async {
  return ref.watch(profileRepositoryProvider).fetchProfile();
});