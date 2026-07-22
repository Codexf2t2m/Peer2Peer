
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/community_fund_repository.dart';

// Remove if supabaseClientProvider is already declared globally.
final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final communityFundRepositoryProvider =
    Provider.autoDispose<CommunityFundRepository>((ref) {
  return CommunityFundRepository(ref.watch(supabaseClientProvider));
});