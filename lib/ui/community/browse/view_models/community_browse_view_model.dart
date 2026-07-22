
// UC: Browse Community Feed + Filter Community Feed
//
// Owns:
//   • The active filter selection
//   • Filtering logic (previously inline in build())
//   • refresh() wired to RefreshIndicator
//
// The filter is part of VM state — not local widget setState — because
// it drives derived data (the filtered list) that belongs in the VM layer.
//
// State shape: AsyncNotifier<CommunityBrowseUiState>
//   Loading → spinner
//   Error   → error card with retry
//   Data    → filtered list + active filter

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/community_member_model.dart';
import '../../../../data/providers/community_providers.dart';

// Filter enum 

/// Promoted from the private _CommunityFilter enum in the original screen.
enum CommunityFilter {
  all,
  contacts,
  highTrust,
  quickReturn;

  String get label => switch (this) {
        CommunityFilter.all => 'All',
        CommunityFilter.contacts => 'Contacts',
        CommunityFilter.highTrust => 'High trust',
        CommunityFilter.quickReturn => 'Quick return',
      };
}

// UI State 

class CommunityBrowseUiState {
  const CommunityBrowseUiState({
    required this.allMembers,
    required this.activeFilter,
  });

  final List<CommunityMemberModel> allMembers;
  final CommunityFilter activeFilter;

  /// The filtered list shown in the feed — derived from allMembers + filter.
  List<CommunityMemberModel> get filteredMembers {
    return allMembers.where((m) {
      return switch (activeFilter) {
        CommunityFilter.all => true,
        // 'contacts' would require a contacts list — returning all for now.
        CommunityFilter.contacts => true,
        CommunityFilter.highTrust => m.isHighTrust,
        CommunityFilter.quickReturn => m.isQuickReturn,
      };
    }).toList();
  }

  bool get isEmpty => filteredMembers.isEmpty;

  CommunityBrowseUiState withFilter(CommunityFilter filter) {
    return CommunityBrowseUiState(
      allMembers: allMembers,
      activeFilter: filter,
    );
  }
}

// ViewModel 

class CommunityBrowseViewModel
    extends AutoDisposeAsyncNotifier<CommunityBrowseUiState> {
  @override
  Future<CommunityBrowseUiState> build() => _load();

  Future<CommunityBrowseUiState> _load() async {
    final members = await ref
        .watch(communityRepositoryProvider)
        .fetchCommunityFeed();

    return CommunityBrowseUiState(
      allMembers: members,
      activeFilter: CommunityFilter.all,
    );
  }

  /// Updates the active filter without reloading from the network.
  /// The filteredMembers getter on UiState recomputes instantly.
  void setFilter(CommunityFilter filter) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.withFilter(filter));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

// Provider 

final communityBrowseViewModelProvider = AsyncNotifierProvider.autoDispose<
    CommunityBrowseViewModel, CommunityBrowseUiState>(
  CommunityBrowseViewModel.new,
);