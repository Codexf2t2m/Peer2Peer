
// UC: View Available Lending Amount + Wallet actions (top-up, transfer, history)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app_routes.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../ui/app_theme.dart';
import '../view_models/wallet_view_model.dart';
import 'top_up_dialog.dart';
import 'transfer_dialog.dart';
import 'wallet_balance_card.dart';
import 'wallet_card_mock.dart';
import 'wallet_history_sheet.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(walletViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Text(
          'Wallet',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.profile),
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedUser,
              color: AppTheme.iconColor,
              size: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(walletViewModelProvider.notifier).refresh(),
          child: uiState.when(
            // Loading 
            loading: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),

            // Error 
            error: (e, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 24),
              children: [
                AppCard(
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFEF4444)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.toString().replaceFirst('Exception: ', ''),
                          style: const TextStyle(
                              color: Color(0xFFEF4444), fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () => ref
                            .read(walletViewModelProvider.notifier)
                            .refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Data 
            data: (state) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.fromLTRB(16, 12, 16, 18),
              children: [
                // Balance + actions 
                WalletBalanceCard(
                  wallet: state.wallet,
                  onTopUp: () => TopUpDialog.show(context),
                  onTransfer: () => TransferDialog.show(context),
                  onHistory: () => WalletHistorySheet.show(
                    context,
                    transactions: state.transactions,
                  ),
                ),

                const SizedBox(height: 18),

                // Card visual 
                const SectionTitle(title: 'Cards'),
                const SizedBox(height: 12),
                const WalletCardMock(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          const BottomNavBar(currentRoute: AppRoutes.wallet),
    );
  }
}