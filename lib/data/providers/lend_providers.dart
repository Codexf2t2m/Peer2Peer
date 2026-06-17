import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lending_activity_model.dart';
import '../models/lending_overview_model.dart';
import '../repositories/lend_repository.dart';

// Infrastructure 

/// Global Supabase client provider.
/// Defined once across the app — if already declared elsewhere, remove this.
final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

// Repository 

final lendRepositoryProvider = Provider.autoDispose<LendRepository>((ref) {
  return LendRepository(ref.watch(supabaseClientProvider));
});

// Raw data providers 
// The view model watches these; screens never watch them directly.

final lendingOverviewDataProvider =
    FutureProvider.autoDispose<LendingOverviewModel>((ref) async {
  return ref.watch(lendRepositoryProvider).fetchLendingOverview();
});

final lendingActivityDataProvider =
    FutureProvider.autoDispose<List<LendingActivityModel>>((ref) async {
  return ref.watch(lendRepositoryProvider).fetchLendingActivity();
});