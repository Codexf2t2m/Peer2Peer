
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/home_overview_model.dart';
import '../repositories/home_repository.dart';

// Remove if supabaseClientProvider is declared globally.
final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final homeRepositoryProvider =
    Provider.autoDispose<HomeRepository>((ref) {
  return HomeRepository(ref.watch(supabaseClientProvider));
});

/// Raw data provider — watched by the VM only.
final homeOverviewDataProvider =
    FutureProvider.autoDispose<HomeOverviewModel>((ref) async {
  return ref.watch(homeRepositoryProvider).fetchHomeOverview();
});