
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/complaint_repository.dart';

// Remove if supabaseClientProvider is already declared globally.
final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final complaintRepositoryProvider =
    Provider.autoDispose<ComplaintRepository>((ref) {
  return ComplaintRepository(ref.watch(supabaseClientProvider));
});