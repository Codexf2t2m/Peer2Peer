
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kutlo_context_model.dart';
import '../repositories/kutlo_repository.dart';

// Infrastructure 
// Remove if supabaseClientProvider is already declared globally.

final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

// Repository 

final kutloRepositoryProvider =
    Provider.autoDispose<KutloRepository>((ref) {
  return KutloRepository(ref.watch(supabaseClientProvider));
});

// User context 
// Loaded once when the screen mounts; the VM watches this.

final kutloContextProvider =
    FutureProvider.autoDispose<KutloContextModel>((ref) async {
  return ref.watch(kutloRepositoryProvider).fetchUserContext();
});