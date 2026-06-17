
// UC: View Credit Score + View Borrowing Limit + View Reputation Score
//     + Earn Badge + Sign Out
//
// Two concerns, two notifiers:
//
//  ProfileViewModel (AsyncNotifier<UserProfileModel>)
//  Owns the read state. Fetches all profile data in one shot
//  (profile + credit + badges + stats via parallel queries in the repo).
//  refresh() wired to RefreshIndicator.
//
//  ProfileSignOutViewModel (Notifier<SignOutState>)
//  Owns the sign-out mutation. The screen's ref.listen reacts to
//  SignOutSuccess by navigating to login — sign-out logic never lives
//  in the widget directly.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/user_profile_model.dart';
import '../../../data/providers/profile_providers.dart';
import '../../../data/providers/session_provider.dart';

// Read ViewModel 

class ProfileViewModel
    extends AutoDisposeAsyncNotifier<UserProfileModel> {
  @override
  Future<UserProfileModel> build() => _load();

  Future<UserProfileModel> _load() async {
    return ref
        .watch(profileRepositoryProvider)
        .fetchProfile();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

final profileViewModelProvider = AsyncNotifierProvider.autoDispose<
    ProfileViewModel, UserProfileModel>(
  ProfileViewModel.new,
);

// Sign-out State 

sealed class SignOutState {
  const SignOutState();
}

class SignOutIdle extends SignOutState {
  const SignOutIdle();
}

class SignOutLoading extends SignOutState {
  const SignOutLoading();
}

class SignOutSuccess extends SignOutState {
  const SignOutSuccess();
}

class SignOutError extends SignOutState {
  const SignOutError(this.message);
  final String message;
}

extension SignOutStateX on SignOutState {
  bool get isLoading => this is SignOutLoading;
}

// Sign-out ViewModel 

class ProfileSignOutViewModel
    extends AutoDisposeNotifier<SignOutState> {
  @override
  SignOutState build() => const SignOutIdle();

  Future<void> signOut() async {
    state = const SignOutLoading();
    try {
      await ref.read(sessionProvider.notifier).signOut();
      state = const SignOutSuccess();
    } catch (e) {
      state = SignOutError(
          e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

final profileSignOutViewModelProvider =
    NotifierProvider.autoDispose<ProfileSignOutViewModel,
        SignOutState>(
  ProfileSignOutViewModel.new,
);