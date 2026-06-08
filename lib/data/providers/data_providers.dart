import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../app_state.dart';
import '../models/credit_profile_model.dart';
import '../models/badge_model.dart';
import '../repositories/bank_connection_repository.dart';
import '../repositories/kyc_repository.dart';
import '../services/credit_service.dart';
import 'session_provider.dart';
import 'supabase_providers.dart';

// ── Demo store (StateNotifier version of DemoStore) ──────────────────────────

class DemoStoreState {
  final List<CommunityMember> communityMembers;
  final List<AppTransaction> transactions;
  final List<AppNotificationItem> notifications;
  final double walletBalance;
  final double extraFunding;

  DemoStoreState({
    required this.communityMembers,
    required this.transactions,
    required this.notifications,
    required this.walletBalance,
    required this.extraFunding,
  });

  DemoStoreState copyWith({
    List<CommunityMember>? communityMembers,
    List<AppTransaction>? transactions,
    List<AppNotificationItem>? notifications,
    double? walletBalance,
    double? extraFunding,
  }) {
    return DemoStoreState(
      communityMembers: communityMembers ?? this.communityMembers,
      transactions: transactions ?? this.transactions,
      notifications: notifications ?? this.notifications,
      walletBalance: walletBalance ?? this.walletBalance,
      extraFunding: extraFunding ?? this.extraFunding,
    );
  }
}

class DemoStoreNotifier extends StateNotifier<DemoStoreState> {
  DemoStoreNotifier()
      : super(
          DemoStoreState(
            communityMembers: [
              const CommunityMember(
                id: 'topo',
                name: 'Topo R.',
                avatarUrl: 'https://i.pravatar.cc/150?img=53',
                subtitle: 'Gaborone-FNB',
                score: 89,
                scoreColor: Color(0xFF00BFA5),
                scoreLabel: 'Trusted',
                about:
                    'Final-year student buying textbooks for exams. Has repaid every request on time.',
                requestDescription:
                    'Need P1,500 for university textbooks, paying back end of month, 30% interest',
                targetAmount: 1500,
                fundedAmount: 450,
                returnAmount: 1950,
                dueIn: '30 days',
                isContact: true,
                isHighTrust: true,
                isQuickReturn: false,
              ),
              const CommunityMember(
                id: 'lefika',
                name: 'Lefika L.',
                avatarUrl: 'https://i.pravatar.cc/150?img=11',
                subtitle: 'Gaborone-Orange Money',
                score: 69,
                scoreColor: Color(0xFFFF8F00),
                scoreLabel: 'Fair',
                about: 'Teacher at a primary school. Has a clean repayment history.',
                requestDescription:
                    'Need P500 for car repair — paying back in 3 weeks with 5% interest',
                targetAmount: 500,
                fundedAmount: 0,
                returnAmount: 525,
                dueIn: '21 days',
                isContact: false,
                isHighTrust: false,
                isQuickReturn: true,
              ),
              const CommunityMember(
                id: 'alex',
                name: 'Alex W.',
                avatarUrl: 'https://i.pravatar.cc/150?img=68',
                subtitle: 'Gaborone-FNB',
                score: 55,
                scoreColor: Color(0xFFE53935),
                scoreLabel: 'Needs review',
                about:
                    'Runs a small delivery business and wants to bridge fuel costs for the week.',
                requestDescription:
                    'Need P1,300 to restock fuel and mobile data, paying back in 3 weeks with 19% interest',
                targetAmount: 1300,
                fundedAmount: 0,
                returnAmount: 1550,
                dueIn: '3 weeks',
                isContact: false,
                isHighTrust: false,
                isQuickReturn: true,
              ),
            ],
            transactions: [
              AppTransaction(
                title: 'Lent to Topo',
                subtitle: 'Today, 9:14am',
                amount: 300,
                isCredit: false,
                icon: HugeIcons.strokeRoundedArrowUpRight01,
                category: TransactionCategory.funding,
                createdAt: DateTime.now().subtract(const Duration(hours: 2)),
              ),
              AppTransaction(
                title: 'Repayment from Tau',
                subtitle: 'Mar 12',
                amount: 420,
                isCredit: true,
                icon: HugeIcons.strokeRoundedArrowDownLeft01,
                category: TransactionCategory.repayment,
                createdAt: DateTime(2026, 3, 12, 11, 30),
              ),
            ],
            notifications: [
              AppNotificationItem(
                title: 'Repayment received',
                message: 'Tau paid back P420 on March 12, 2026.',
                createdAt: DateTime(2026, 3, 12, 11, 30),
              ),
              AppNotificationItem(
                title: 'Welcome back',
                message: 'Your wallet and community activity are ready.',
                createdAt: DateTime.now().subtract(const Duration(hours: 6)),
              ),
            ],
            walletBalance: 500,
            extraFunding: 0,
          ),
        );

  FundingResult fundMember({required String memberId, required double amount}) {
    if (amount <= 0) {
      return const FundingResult(
        success: false,
        message: 'Enter a valid amount.',
      );
    }

    final members = List<CommunityMember>.from(state.communityMembers);
    final index = members.indexWhere((m) => m.id == memberId);
    if (index == -1) {
      return const FundingResult(
        success: false,
        message: 'Borrower not found.',
      );
    }

    final member = members[index];
    final remaining = member.remainingAmount;

    if (remaining <= 0) {
      return const FundingResult(
        success: false,
        message: 'This request is already fully funded.',
      );
    }

    if (amount > state.walletBalance) {
      return FundingResult(
        success: false,
        message: 'You only have P${state.walletBalance} available.',
      );
    }

    final fundedAmount = amount > remaining ? remaining : amount;
    members[index] = member.copyWith(
      fundedAmount: member.fundedAmount + fundedAmount,
    );

    final updatedTx = List<AppTransaction>.from(state.transactions);
    final timestamp = DateTime.now();
    updatedTx.insert(
      0,
      AppTransaction(
        title: 'Funded ${member.name}',
        subtitle: formatActivityTime(timestamp),
        amount: fundedAmount,
        isCredit: false,
        icon: HugeIcons.strokeRoundedArrowUpRight01,
        category: TransactionCategory.funding,
        createdAt: timestamp,
      ),
    );

    final updatedNotifications = List<AppNotificationItem>.from(state.notifications);
    updatedNotifications.insert(
      0,
      AppNotificationItem(
        title: 'Funding sent',
        message: 'You funded ${member.name} with P$fundedAmount.',
        createdAt: timestamp,
      ),
    );

    state = state.copyWith(
      communityMembers: members,
      walletBalance: state.walletBalance - fundedAmount,
      extraFunding: state.extraFunding + fundedAmount,
      transactions: updatedTx,
      notifications: updatedNotifications,
    );

    return FundingResult(
      success: true,
      message: 'You funded ${member.name} with P$fundedAmount.',
    );
  }

  FundingResult topUpWallet(double amount) {
    if (amount <= 0) {
      return const FundingResult(
        success: false,
        message: 'Enter a valid amount.',
      );
    }

    final updatedTx = List<AppTransaction>.from(state.transactions);
    final timestamp = DateTime.now();
    updatedTx.insert(
      0,
      AppTransaction(
        title: 'Wallet top up',
        subtitle: formatActivityTime(timestamp),
        amount: amount,
        isCredit: true,
        icon: HugeIcons.strokeRoundedPlusSign,
        category: TransactionCategory.wallet,
        createdAt: timestamp,
      ),
    );

    final updatedNotifications = List<AppNotificationItem>.from(state.notifications);
    updatedNotifications.insert(
      0,
      AppNotificationItem(
        title: 'Wallet updated',
        message: 'You topped up P$amount.',
        createdAt: timestamp,
      ),
    );

    state = state.copyWith(
      walletBalance: state.walletBalance + amount,
      transactions: updatedTx,
      notifications: updatedNotifications,
    );

    return FundingResult(
      success: true,
      message: 'Wallet topped up by P$amount.',
    );
  }

  FundingResult transferFromWallet({
    required double amount,
    required String recipient,
  }) {
    if (amount <= 0) {
      return const FundingResult(
        success: false,
        message: 'Enter a valid amount.',
      );
    }
    if (recipient.trim().isEmpty) {
      return const FundingResult(success: false, message: 'Enter a recipient.');
    }
    if (amount > state.walletBalance) {
      return FundingResult(
        success: false,
        message: 'You only have P${state.walletBalance} available.',
      );
    }

    final updatedTx = List<AppTransaction>.from(state.transactions);
    final timestamp = DateTime.now();
    updatedTx.insert(
      0,
      AppTransaction(
        title: 'Transfer to ${recipient.trim()}',
        subtitle: formatActivityTime(timestamp),
        amount: amount,
        isCredit: false,
        icon: HugeIcons.strokeRoundedArrowLeftRight,
        category: TransactionCategory.wallet,
        createdAt: timestamp,
      ),
    );

    final updatedNotifications = List<AppNotificationItem>.from(state.notifications);
    updatedNotifications.insert(
      0,
      AppNotificationItem(
        title: 'Transfer complete',
        message: 'You sent P$amount to ${recipient.trim()}.',
        createdAt: timestamp,
      ),
    );

    state = state.copyWith(
      walletBalance: state.walletBalance - amount,
      transactions: updatedTx,
      notifications: updatedNotifications,
    );

    return FundingResult(
      success: true,
      message: 'Transferred P$amount to ${recipient.trim()}.',
    );
  }

  FundingResult submitRequest({required double amount, required String note}) {
    if (amount <= 0) {
      return const FundingResult(
        success: false,
        message: 'Enter a valid amount.',
      );
    }

    final timestamp = DateTime.now();
    final summary = note.trim().isEmpty ? 'No note added.' : note.trim();
    final updatedNotifications = List<AppNotificationItem>.from(state.notifications);
    updatedNotifications.insert(
      0,
      AppNotificationItem(
        title: 'Request submitted',
        message: 'Your request for P$amount is live. $summary',
        createdAt: timestamp,
      ),
    );

    state = state.copyWith(notifications: updatedNotifications);

    return FundingResult(
      success: true,
      message: 'Request submitted for P$amount.',
    );
  }
}

final demoStoreProvider = StateNotifierProvider<DemoStoreNotifier, DemoStoreState>((ref) {
  return DemoStoreNotifier();
});

/// Active loans the current user is a borrower on.
final activeLoansProvider = FutureProvider((ref) async {
  final session = ref.watch(sessionProvider);
  if (session.supabaseEnabled && session.isSignedIn) {
    final loanRepo = ref.watch(loanRepositoryProvider);
    return loanRepo.fetchMyActiveLoansAsBorrower();
  }
  return [];
});

/// All loan requests the current user has submitted as a borrower.
final myLoanRequestsProvider = FutureProvider((ref) async {
  final session = ref.watch(sessionProvider);
  if (session.supabaseEnabled && session.isSignedIn) {
    final loanRepo = ref.watch(loanRepositoryProvider);
    return loanRepo.fetchMyLoanRequests();
  }
  return [];
});

/// All contributions the current user has made as a lender.
final myContributionsProvider = FutureProvider((ref) async {
  final session = ref.watch(sessionProvider);
  if (session.supabaseEnabled && session.isSignedIn) {
    final loanRepo = ref.watch(loanRepositoryProvider);
    return loanRepo.fetchMyContributions();
  }
  return [];
});



// ── Shared UI Feeds Providers (Handles Live / Demo state switching) ──────────

final communityMembersProvider = FutureProvider<List<CommunityMember>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session.supabaseEnabled && session.isSignedIn) {
    final loanRepo = ref.watch(loanRepositoryProvider);
    final requests = await loanRepo.fetchActiveCommunityRequests();

    return requests.map((req) {
      final scoreStr = req.borrowerReputationScore ?? 'NEW';
      final score = switch (scoreStr.toUpperCase()) {
        'A' => 90,
        'B' => 75,
        'C' => 60,
        'NEW' => 50,
        _ => 50,
      };
      final scoreLabel = switch (scoreStr.toUpperCase()) {
        'A' => 'Trusted',
        'B' => 'Fair',
        'C' => 'Needs review',
        _ => 'New Joiner',
      };
      final scoreColor = switch (scoreStr.toUpperCase()) {
        'A' => const Color(0xFF00BFA5),
        'B' => const Color(0xFFFF8F00),
        _ => const Color(0xFFE53935),
      };

      return CommunityMember(
        id: req.id,
        name: req.displayName,
        avatarUrl: 'https://i.pravatar.cc/150?u=${req.borrowerId}',
        subtitle: 'Gaborone-FNB',
        score: score,
        scoreColor: scoreColor,
        scoreLabel: scoreLabel,
        about: req.purpose ?? 'No details provided.',
        requestDescription: req.purpose ?? 'Needs funding for community request.',
        targetAmount: req.amountRequested,
        fundedAmount: req.fundedAmount,
        returnAmount: req.expectedReturn,
        dueIn: req.dueIn,
        isContact: false,
        isHighTrust: score >= 80,
        isQuickReturn: req.durationDays <= 30,
      );
    }).toList();
  } else {
    return ref.watch(demoStoreProvider).communityMembers;
  }
});

final walletBalanceProvider = FutureProvider<double>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session.supabaseEnabled && session.isSignedIn) {
    final profileRepo = ref.watch(profileRepositoryProvider);
    return profileRepo.fetchWalletBalance();
  } else {
    return ref.watch(demoStoreProvider).walletBalance;
  }
});

final transactionsProvider = FutureProvider<List<AppTransaction>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session.supabaseEnabled && session.isSignedIn) {
    final txRepo = ref.watch(transactionRepositoryProvider);
    final txs = await txRepo.fetchMyTransactions();

    return txs.map((t) {
      final isCredit = t.type == 'deposit' || t.type == 'repayment' || t.type == 'interest';
      final icon = switch (t.type) {
        'deposit' => HugeIcons.strokeRoundedPlusSign,
        'funding' => HugeIcons.strokeRoundedArrowUpRight01,
        'withdrawal' => HugeIcons.strokeRoundedArrowLeftRight,
        'repayment' => HugeIcons.strokeRoundedArrowDownLeft01,
        _ => HugeIcons.strokeRoundedArrowDownLeft01,
      };
      final title = switch (t.type) {
        'deposit' => 'Wallet top up',
        'funding' => 'Lent to borrower',
        'withdrawal' => 'Transfer/Withdrawal',
        'repayment' => 'Repayment received',
        'fee' => 'Platform fee',
        _ => 'Transaction',
      };
      final category = switch (t.type) {
        'funding' => TransactionCategory.funding,
        'repayment' => TransactionCategory.repayment,
        _ => TransactionCategory.wallet,
      };

      return AppTransaction(
        title: title,
        subtitle: formatActivityTime(t.createdAt),
        amount: t.netAmount,
        isCredit: isCredit,
        icon: icon,
        category: category,
        createdAt: t.createdAt,
      );
    }).toList();
  } else {
    return ref.watch(demoStoreProvider).transactions;
  }
});

final notificationsProvider = FutureProvider<List<AppNotificationItem>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session.supabaseEnabled && session.isSignedIn) {
    final notifRepo = ref.watch(notificationRepositoryProvider);
    final items = await notifRepo.fetchMyNotifications();

    return items.map((n) {
      return AppNotificationItem(
        title: n.type.split('_').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' '),
        message: n.message,
        createdAt: n.createdAt,
      );
    }).toList();
  } else {
    return ref.watch(demoStoreProvider).notifications;
  }
});

final lendingOverviewProvider = FutureProvider<Map<String, double>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session.supabaseEnabled && session.isSignedIn) {
    final profileRepo = ref.watch(profileRepositoryProvider);
    return profileRepo.fetchLendingOverview();
  } else {
    final store = ref.watch(demoStoreProvider);
    return {
      'total_lent': 1348 + store.extraFunding,
      'interest_earned': 538 + (store.extraFunding * 0.08),
    };
  }
});

final profileStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session.supabaseEnabled && session.isSignedIn) {
    final profileRepo = ref.watch(profileRepositoryProvider);
    return profileRepo.fetchProfileStats();
  } else {
    return {
      'total_requested': 12,
      'fully_repaid': 9,
      'people_funded': 5,
      'late_payments': 0,
    };
  }
});

final creditProfileProvider = FutureProvider<CreditProfileModel?>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session.supabaseEnabled && session.isSignedIn) {
    final profileRepo = ref.watch(profileRepositoryProvider);
    return profileRepo.fetchCreditProfile();
  }
  return null;
});

final userBadgesProvider = FutureProvider<List<UserBadgeModel>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session.supabaseEnabled && session.isSignedIn) {
    final profileRepo = ref.watch(profileRepositoryProvider);
    return profileRepo.fetchUserBadges();
  }
  return [];
});

// ── Controllers for Actions (Loading/Error Mutators) ─────────────────────────

class FundingController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> fundLoan({
    required String loanRequestId,
    required double amount,
  }) async {
    state = const AsyncLoading();
    final session = ref.read(sessionProvider);

    if (session.supabaseEnabled && session.isSignedIn) {
      final loanRepo = ref.read(loanRepositoryProvider);
      state = await AsyncValue.guard(() async {
        await loanRepo.fundLoanRequest(
          loanRequestId: loanRequestId,
          amount: amount,
        );
        // Refresh all feeds
        ref.invalidate(walletBalanceProvider);
        ref.invalidate(lendingOverviewProvider);
        ref.invalidate(transactionsProvider);
        ref.invalidate(communityMembersProvider);
      });
    } else {
      final result = ref.read(demoStoreProvider.notifier).fundMember(
        memberId: loanRequestId,
        amount: amount,
      );
      if (result.success) {
        state = const AsyncData(null);
      } else {
        state = AsyncError(Exception(result.message), StackTrace.current);
      }
    }
    return !state.hasError;
  }
}

final fundingControllerProvider =
    AutoDisposeAsyncNotifierProvider<FundingController, void>(() {
  return FundingController();
});

class WalletController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> topUp(double amount) async {
    state = const AsyncLoading();
    final session = ref.read(sessionProvider);

    if (session.supabaseEnabled && session.isSignedIn) {
      final txRepo = ref.read(transactionRepositoryProvider);
      state = await AsyncValue.guard(() async {
        await txRepo.insertTransaction(
          amount: amount,
          type: 'deposit',
          status: 'completed',
        );
        ref.invalidate(walletBalanceProvider);
        ref.invalidate(transactionsProvider);
      });
    } else {
      final result = ref.read(demoStoreProvider.notifier).topUpWallet(amount);
      if (result.success) {
        state = const AsyncData(null);
      } else {
        state = AsyncError(Exception(result.message), StackTrace.current);
      }
    }
    return !state.hasError;
  }

  Future<bool> transfer(double amount, String recipient) async {
    state = const AsyncLoading();
    final session = ref.read(sessionProvider);

    if (session.supabaseEnabled && session.isSignedIn) {
      final txRepo = ref.read(transactionRepositoryProvider);
      final profileRepo = ref.read(profileRepositoryProvider);

      state = await AsyncValue.guard(() async {
        final balance = await profileRepo.fetchWalletBalance();
        if (amount > balance) {
          throw Exception('You only have P$balance available in your wallet.');
        }

        await txRepo.insertTransaction(
          amount: amount,
          type: 'withdrawal',
          status: 'completed',
        );
        ref.invalidate(walletBalanceProvider);
        ref.invalidate(transactionsProvider);
      });
    } else {
      final result = ref.read(demoStoreProvider.notifier).transferFromWallet(
            amount: amount,
            recipient: recipient,
          );
      if (result.success) {
        state = const AsyncData(null);
      } else {
        state = AsyncError(Exception(result.message), StackTrace.current);
      }
    }
    return !state.hasError;
  }
}

final walletControllerProvider =
    AutoDisposeAsyncNotifierProvider<WalletController, void>(() {
  return WalletController();
});

class LoanRequestController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> submitRequest({
    required double amount,
    required double interestRate,
    required int durationDays,
    required String purpose,
  }) async {
    state = const AsyncLoading();
    final session = ref.read(sessionProvider);

    if (session.supabaseEnabled && session.isSignedIn) {
      final loanRepo = ref.read(loanRepositoryProvider);
      state = await AsyncValue.guard(() async {
        await loanRepo.submitLoanRequest(
          amountRequested: amount,
          interestRate: interestRate,
          durationDays: durationDays,
          purpose: purpose,
          requestType: 'community',
        );
        ref.invalidate(communityMembersProvider);
      });
    } else {
      final result = ref.read(demoStoreProvider.notifier).submitRequest(
            amount: amount,
            note: purpose,
          );
      if (result.success) {
        state = const AsyncData(null);
      } else {
        state = AsyncError(Exception(result.message), StackTrace.current);
      }
    }
    return !state.hasError;
  }
}

final loanRequestControllerProvider =
    AutoDisposeAsyncNotifierProvider<LoanRequestController, void>(() {
  return LoanRequestController();
});

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches the current user's onboarding step from the database.
/// Returns 'active' in demo mode so the home screen is accessible.
final onboardingStepProvider = FutureProvider<String>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session.supabaseEnabled && session.isSignedIn) {
    final profileRepo = ref.watch(profileRepositoryProvider);
    return profileRepo.fetchOnboardingStep();
  }
  return 'active';
});

/// Fetches all active bank connections for the signed-in user.
final bankConnectionsProvider = FutureProvider((ref) async {
  final session = ref.watch(sessionProvider);
  if (session.supabaseEnabled && session.isSignedIn) {
    final bankRepo = ref.watch(bankConnectionRepositoryProvider);
    return bankRepo.fetchActiveConnections();
  }
  return [];
});

/// Fetches all KYC documents for the signed-in user.
final kycDocumentsProvider = FutureProvider((ref) async {
  final session = ref.watch(sessionProvider);
  if (session.supabaseEnabled && session.isSignedIn) {
    final kycRepo = ref.watch(kycRepositoryProvider);
    return kycRepo.fetchMyDocuments();
  }
  return [];
});

/// Controller that orchestrates onboarding step transitions.
class OnboardingController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Called after the user taps "I've verified my email".
  /// Polls the Supabase session for email_confirmed_at and advances step.
  Future<bool> confirmEmailVerified() async {
    state = const AsyncLoading();
    final session = ref.read(sessionProvider);

    if (!session.supabaseEnabled) {
      state = const AsyncData(null);
      return true;
    }

    try {
      // Refresh the session to get the latest user data
      await ref.read(supabaseClientProvider).auth.refreshSession();
      final user = ref.read(supabaseClientProvider).auth.currentUser;

      if (user?.emailConfirmedAt == null) {
        state = AsyncError(
          Exception('Your email has not been confirmed yet. Please check your inbox.'),
          StackTrace.current,
        );
        return false;
      }

      final profileRepo = ref.read(profileRepositoryProvider);
      await profileRepo.updateOnboardingStep('email_verified');
      ref.invalidate(onboardingStepProvider);
      state = const AsyncData(null);
      return true;
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  /// Called after Stitch OAuth completes.
  Future<bool> completeBankConnect({
    required String provider,
    required String bankName,
    required String accountId,
  }) async {
    state = const AsyncLoading();
    final session = ref.read(sessionProvider);

    if (!session.supabaseEnabled) {
      state = const AsyncData(null);
      return true;
    }

    try {
      final bankRepo = ref.read(bankConnectionRepositoryProvider);
      await bankRepo.createConnection(
        provider: provider,
        bankName: bankName,
        accountIdExternal: accountId,
      );
      ref.invalidate(bankConnectionsProvider);
      ref.invalidate(onboardingStepProvider);
      state = const AsyncData(null);
      return true;
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  /// Runs the credit assessment and completes onboarding.
  Future<CreditAssessmentResult?> runCreditAssessment() async {
    state = const AsyncLoading();
    final session = ref.read(sessionProvider);
    final userId = session.currentUserId;

    if (!session.supabaseEnabled || userId == null) {
      // Demo mode – return a synthetic result
      await Future<void>.delayed(const Duration(seconds: 2));
      state = const AsyncData(null);
      return const CreditAssessmentResult(
        creditScore: 720,
        riskBand: 'Good',
        borrowingLimit: 3000,
        modelVersion: 'demo',
      );
    }

    CreditAssessmentResult? result;
    state = await AsyncValue.guard(() async {
      final creditSvc = ref.read(creditServiceProvider);
      result = await creditSvc.runAssessment(userId);
      ref.invalidate(creditProfileProvider);
      ref.invalidate(onboardingStepProvider);
      ref.invalidate(notificationsProvider);
    });

    return result;
  }
}

final onboardingControllerProvider =
    AutoDisposeAsyncNotifierProvider<OnboardingController, void>(() {
  return OnboardingController();
});

