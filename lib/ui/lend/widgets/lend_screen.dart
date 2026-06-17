// UC: View Lending Portfolio + Fund Community Loan entry point.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app_routes.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../ui/app_theme.dart';
import '../view_models/lend_view_model.dart';
import 'lending_activity_sheet.dart';
import 'lending_activity_tile.dart';
import 'lending_portfolio_card.dart';

class LendScreen extends ConsumerWidget {
  const LendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(lendViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Text('Lend', style: Theme.of(context).textTheme.titleMedium),
        actions: [
          IconButton(
            tooltip: 'Browse community loans',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.community),
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedAddSquare,
              color: AppTheme.iconColor,
              size: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(lendViewModelProvider.notifier).refresh(),
          child: uiState.when(
            // Loading 
            loading: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),

            // Error 
            error: (e, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                            .read(lendViewModelProvider.notifier)
                            .refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            //  Data 
            data: (state) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.fromLTRB(16, 12, 16, 18),
              children: [
                //  Portfolio summary 
                const SectionTitle(title: 'Your lending'),
                const SizedBox(height: 12),
                LendingPortfolioCard(overview: state.overview),

                const SizedBox(height: 18),

                //  Recent activity 
                SectionTitle(
                  title: 'Active loans',
                  trailing: TextButton(
                    onPressed: state.hasActivity
                        ? () => LendingActivitySheet.show(
                              context,
                              activities: state.allActivity,
                            )
                        : null,
                    child: const Text('View all'),
                  ),
                ),
                const SizedBox(height: 12),

                if (!state.hasActivity)
                  const AppCard(
                    child: Text('No lending activity yet.'),
                  )
                else
                  ...state.recentActivity.map(
                    (activity) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LendingActivityTile(activity: activity),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          const BottomNavBar(currentRoute: AppRoutes.lend),
    );
  }
}