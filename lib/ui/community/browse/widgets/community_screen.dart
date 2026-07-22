
// UC: Browse Community Feed + Filter Community Feed
//
// Architecture
// • ConsumerWidget — no local state at all.
//   Filter selection and filtering logic live in CommunityBrowseViewModel.
//
// • Watches [communityBrowseViewModelProvider] only — one
//   AsyncValue<CommunityBrowseUiState>.
//
// • setFilter() is called directly on the notifier — no setState needed
//   because the VM recomputes filteredMembers and Riverpod rebuilds the
//   screen automatically.
//
// • RefreshIndicator calls vm.refresh().

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app_routes.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../view_models/community_browse_view_model.dart';
import 'community_filter_bar.dart';
import 'community_member_card.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(communityBrowseViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref
              .read(communityBrowseViewModelProvider.notifier)
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
                const SizedBox(height: 24),
                const Text(
                  'Community',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                            .read(communityBrowseViewModelProvider
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
            data: (state) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title 
                const Padding(
                  padding:
                      EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Text(
                    'Community',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ),

                // Filter chips 
                CommunityFilterBar(
                  activeFilter: state.activeFilter,
                  onFilterChanged: (filter) => ref
                      .read(communityBrowseViewModelProvider
                          .notifier)
                      .setFilter(filter),
                ),

                const SizedBox(height: 20),

                // Feed list 
                Expanded(
                  child: state.isEmpty
                      ? const EmptyState(
                          message:
                              'No borrowers match this filter yet.',
                        )
                      : ListView.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20),
                          itemCount: state.filteredMembers.length,
                          itemBuilder: (context, index) {
                            final member =
                                state.filteredMembers[index];
                            return CommunityMemberCard(
                              member: member,
                              onFund: () =>
                                  Navigator.of(context).pushNamed(
                                AppRoutes.communityFund,
                                arguments: member.loanRequestId,
                              ),
                              onViewProfile: () =>
                                  Navigator.of(context).pushNamed(
                                AppRoutes.communityFund,
                                arguments: member.loanRequestId,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          const BottomNavBar(currentRoute: AppRoutes.community),
    );
  }
}