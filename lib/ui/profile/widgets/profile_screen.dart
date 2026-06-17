
// UC: View Credit Score + View Borrowing Limit + View Reputation Score
//     + Earn Badge + Sign Out
//
// Architecture
// • ConsumerWidget — zero local state.
// • Watches ONE AsyncValue<UserProfileModel> from profileViewModelProvider.
//   No more three separate .when() calls for the same screen.
// • ref.listen on profileSignOutViewModelProvider handles navigation
//   to login after sign-out — nav never lives in the widget directly.
// • All private methods (_buildChip, _buildStatCard, _buildAchievementBadge)
//   replaced by extracted widgets.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app_routes.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../ui/widgets/app_back_button.dart';
import '../view_models/profile_view_model.dart';
import 'borrowing_limit_card.dart';
import 'credit_score_card.dart';
import 'profile_badges_section.dart';
import 'profile_header.dart';
import 'profile_stats_grid.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sign-out side effect 
    ref.listen(profileSignOutViewModelProvider, (_, next) {
      if (next is SignOutSuccess) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    });

    final uiState = ref.watch(profileViewModelProvider);
    final signOutState =
        ref.watch(profileSignOutViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop()
            ? const AppBackButton()
            : null,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref
              .read(profileViewModelProvider.notifier)
              .refresh(),
          child: uiState.when(
            // Loading 
            loading: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),

            // Error 
            error: (e, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                AppCard(
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFEF4444)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.toString().replaceFirst(
                              'Exception: ', ''),
                          style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () => ref
                            .read(profileViewModelProvider
                                .notifier)
                            .refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Data 
            data: (profile) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [
                  // Profile header 
                  ProfileHeader(profile: profile),

                  const SizedBox(height: 32),

                  // Credit score 
                  CreditScoreCard(
                    creditProfile: profile.creditProfile,
                  ),

                  const SizedBox(height: 32),

                  // Stats grid 
                  ProfileStatsGrid(stats: profile.stats),

                  const SizedBox(height: 32),

                  // Badges 
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ProfileBadgesSection(
                      badges: profile.badges,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Borrowing limit 
                  BorrowingLimitCard(
                    creditProfile: profile.creditProfile,
                  ),

                  const SizedBox(height: 32),

                  // Sign out 
                  TextButton(
                    onPressed: signOutState.isLoading
                        ? null
                        : () => ref
                            .read(profileSignOutViewModelProvider
                                .notifier)
                            .signOut(),
                    child: signOutState.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
                          )
                        : Text(
                            'Sign out',
                            style: TextStyle(
                              color: Colors.red.shade300,
                              fontSize: 13,
                            ),
                          ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}