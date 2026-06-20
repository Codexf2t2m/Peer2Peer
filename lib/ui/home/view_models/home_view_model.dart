
// UC: View Available Lending Amount, View Monthly Statement,
//     View Borrowing Limit overview, Browse (search entry point)
//
// Single AsyncNotifier<HomeOverviewModel> — one provider, one
// AsyncValue, one loading state, one refresh call.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/home_overview_model.dart';
import '../../../data/providers/home_providers.dart';

class HomeViewModel
    extends AutoDisposeAsyncNotifier<HomeOverviewModel> {
  @override
  Future<HomeOverviewModel> build() => _load();

  Future<HomeOverviewModel> _load() async {
    return ref
        .watch(homeRepositoryProvider)
        .fetchHomeOverview();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

final homeViewModelProvider = AsyncNotifierProvider.autoDispose<
    HomeViewModel, HomeOverviewModel>(
  HomeViewModel.new,
);