import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/bank_connection_repository.dart';
import '../repositories/kyc_repository.dart';
import '../repositories/loan_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/transaction_repository.dart';
import '../services/credit_service.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProfileRepository(client);
});

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return LoanRepository(client);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TransactionRepository(client);
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return NotificationRepository(client);
});

final bankConnectionRepositoryProvider = Provider<BankConnectionRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return BankConnectionRepository(client);
});

final kycRepositoryProvider = Provider<KycRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return KycRepository(client);
});

final creditServiceProvider = Provider<CreditService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CreditService(client);
});
