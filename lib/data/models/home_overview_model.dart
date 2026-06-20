
// Aggregates everything HomeScreen needs in one typed object.
// Replaces the raw Map<String,dynamic> from lendingOverviewProvider
// and the generic AppTransaction list from transactionsProvider.
//
// Sources:
//   get_lending_overview RPC → total_lent, interest_earned, repayment_rate
//   PROFILES                 → available_lending_amount (wallet balance)
//   TRANSACTIONS             → recent 2 + full list
//   NOTIFICATIONS            → unread count + list

import 'notification_model.dart';
import 'wallet_transaction_model.dart';

class HomeOverviewModel {
  const HomeOverviewModel({
    required this.displayName,
    required this.walletBalance,
    required this.totalLent,
    required this.interestEarned,
    required this.repaymentRatePercent,
    required this.monthlyDeltaPula,
    required this.recentTransactions,
    required this.allTransactions,
    required this.notifications,
  });

  final String displayName;
  final double walletBalance;
  final double totalLent;
  final double interestEarned;

  /// Repayment rate as a 0–100 integer for display (e.g. 91).
  final int repaymentRatePercent;

  /// Monthly earnings delta in BWP for the performance card.
  final double monthlyDeltaPula;

  final List<WalletTransactionModel> recentTransactions;
  final List<WalletTransactionModel> allTransactions;
  final List<NotificationModel> notifications;

  int get unreadNotificationCount =>
      notifications.where((n) => !n.isRead).length;

  bool get hasUnreadNotifications => unreadNotificationCount > 0;

  static const empty = HomeOverviewModel(
    displayName: '',
    walletBalance: 0,
    totalLent: 0,
    interestEarned: 0,
    repaymentRatePercent: 0,
    monthlyDeltaPula: 0,
    recentTransactions: [],
    allTransactions: [],
    notifications: [],
  );
}