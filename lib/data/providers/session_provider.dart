import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app_state.dart' show SignUpResult;

class SessionState {
  final bool supabaseEnabled;
  final String? currentEmail;
  final String? currentUserId;
  final bool isSignedIn;
  final bool isLoading;
  final String? error;

  SessionState({
    required this.supabaseEnabled,
    this.currentEmail,
    this.currentUserId,
    required this.isSignedIn,
    this.isLoading = false,
    this.error,
  });

  SessionState copyWith({
    bool? supabaseEnabled,
    String? currentEmail,
    String? currentUserId,
    bool? isSignedIn,
    bool? isLoading,
    String? error,
  }) {
    return SessionState(
      supabaseEnabled: supabaseEnabled ?? this.supabaseEnabled,
      currentEmail: currentEmail ?? this.currentEmail,
      currentUserId: currentUserId ?? this.currentUserId,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier()
      : super(SessionState(supabaseEnabled: false, isSignedIn: false));

  String? _demoEmail;

  SupabaseClient get _client => Supabase.instance.client;

  Future<void> bootstrap() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      state = SessionState(supabaseEnabled: false, isSignedIn: false);
      return;
    }

    final url = dotenv.env['SUPABASE_URL']?.trim() ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';
    final hasValidUrl = Uri.tryParse(url)?.hasAbsolutePath ?? false;

    if (url.isEmpty || anonKey.isEmpty || !hasValidUrl) {
      state = SessionState(supabaseEnabled: false, isSignedIn: false);
      return;
    }

    try {
      await Supabase.initialize(url: url, anonKey: anonKey);
      final currentUser = _client.auth.currentUser;
      state = SessionState(
        supabaseEnabled: true,
        isSignedIn: currentUser != null,
        currentEmail: currentUser?.email,
        currentUserId: currentUser?.id,
      );
    } catch (e) {
      state = SessionState(supabaseEnabled: false, isSignedIn: false);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (state.supabaseEnabled) {
        final response = await _client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        state = state.copyWith(
          isSignedIn: true,
          currentEmail: response.user?.email,
          currentUserId: response.user?.id,
          isLoading: false,
        );
      } else {
        _demoEmail = email;
        state = state.copyWith(
          isSignedIn: true,
          currentEmail: email,
          currentUserId: 'demo-user-id',
          isLoading: false,
        );
      }
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected authentication error occurred.');
      rethrow;
    }
  }

  Future<SignUpResult> signUp({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (state.supabaseEnabled) {
        final response = await _client.auth.signUp(
          email: email,
          password: password,
        );
        state = state.copyWith(isLoading: false);
        if (response.session == null) {
          return const SignUpResult(
            signedIn: false,
            message: 'Check your email to confirm your account, then log in.',
          );
        }
        state = state.copyWith(
          isSignedIn: true,
          currentEmail: response.user?.email,
          currentUserId: response.user?.id,
        );
        return const SignUpResult(signedIn: true);
      } else {
        _demoEmail = email;
        state = state.copyWith(
          isSignedIn: true,
          currentEmail: email,
          currentUserId: 'demo-user-id',
          isLoading: false,
        );
        return const SignUpResult(signedIn: true);
      }
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to create account.');
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    if (state.supabaseEnabled) {
      try {
        await _client.auth.resetPasswordForEmail(email);
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (state.supabaseEnabled) {
        await _client.auth.signOut();
      } else {
        _demoEmail = null;
      }
      state = SessionState(
        supabaseEnabled: state.supabaseEnabled,
        isSignedIn: false,
        currentEmail: null,
        currentUserId: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to log out.');
    }
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier();
});
