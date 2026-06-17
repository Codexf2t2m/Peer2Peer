
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/community_member_model.dart';
import '../repositories/community_repository.dart';

// Remove if supabaseClientProvider is already declared globally.
final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final communityRepositoryProvider =
    Provider.autoDispose<CommunityRepository>((ref) {
  return CommunityRepository(ref.watch(supabaseClientProvider));
});

/// Raw data provider — watched by the VM only, never by the screen.
final communityFeedDataProvider =
    FutureProvider.autoDispose<List<CommunityMemberModel>>((ref) async {
  return ref.watch(communityRepositoryProvider).fetchCommunityFeed();
});