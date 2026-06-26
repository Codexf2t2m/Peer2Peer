
// Manages the full Kutlo conversation lifecycle.

//  KutloViewModel (AsyncNotifier<KutloUiState>)
//  Owns the conversation history and the loaded user context.
//  build() loads the context; the screen shows a loading state until ready.
//
//  KutloSendState / KutloViewModel.send()
//  send() is a method on the same notifier that appends the user message,
//  sets isSending = true, calls the repository, then appends the reply.
//  This keeps history and sending state co-located — they change together.
//
// Suggestion chips
// The use-case diagram has five Kutlo actions.  Each maps to a pre-built
// suggestion the user can tap to fill the input field:
//   • Financial Guidance        → general question
//   • Lending Suggestions       → "How much can I safely lend?"
//   • Run Credit Assessment     → "What does my credit score mean?"
//   • Overdraft Protection      → "Am I at overdraft risk?"
//   • Explain Limit Changes     → "Why did my borrowing limit change?"

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/kutlo_context_model.dart';
import '../../../data/models/kutlo_message_model.dart';
import '../../../data/providers/kutlo_providers.dart';

// UI State 

/// Immutable snapshot of the Kutlo conversation screen.
class KutloUiState {
  const KutloUiState({
    required this.context,
    required this.messages,
    this.isSending = false,
    this.sendError,
  });

  /// The user's financial context — used to personalise every reply.
  final KutloContextModel context;

  /// Full conversation history, oldest first.
  final List<KutloMessageModel> messages;

  /// True while a message is in flight to the Edge Function.
  final bool isSending;

  /// Non-null when the last send attempt failed.
  final String? sendError;

  bool get hasMessages => messages.isNotEmpty;
  bool get hasError => sendError != null;

  KutloUiState copyWith({
    List<KutloMessageModel>? messages,
    bool? isSending,
    String? sendError,
    bool clearError = false,
  }) {
    return KutloUiState(
      context: context,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      sendError: clearError ? null : (sendError ?? this.sendError),
    );
  }
}

// Suggestion chips 

/// Pre-built prompts that map to Kutlo's five use cases.
class KutloSuggestion {
  const KutloSuggestion({required this.label, required this.prompt});
  final String label;
  final String prompt;
}

const kutloSuggestions = [
  KutloSuggestion(
    label: 'How much can I lend?',
    prompt:
        'Based on my current balance and profile, how much can I safely lend this month?',
  ),
  KutloSuggestion(
    label: 'What does my credit score mean?',
    prompt:
        'Can you explain what my current credit score means and how it affects my borrowing limit?',
  ),
  KutloSuggestion(
    label: 'Am I at overdraft risk?',
    prompt:
        'Looking at my active loans and balance, am I at risk of going into overdraft?',
  ),
  KutloSuggestion(
    label: 'Why did my limit change?',
    prompt:
        'My borrowing or lending limit seems to have changed. Can you explain why?',
  ),
  KutloSuggestion(
    label: 'Help me write a loan request',
    prompt:
        'How do I write a strong loan request that lenders will be confident funding?',
  ),
];

// ViewModel 

class KutloViewModel
    extends AutoDisposeAsyncNotifier<KutloUiState> {
  @override
  Future<KutloUiState> build() async {
    final context =
        await ref.watch(kutloRepositoryProvider).fetchUserContext();

    return KutloUiState(
      context: context,
      messages: const [],
    );
  }

  /// Appends [text] as a user message, sends the full history to the
  /// repository, and appends the assistant reply.
  ///
  /// State transitions:
  ///   data(isSending: false) → data(+user msg, isSending: true)
  ///                          → data(+assistant msg, isSending: false)
  ///                          → data(sendError: '...', isSending: false) on fail
  Future<void> send(String text) async {
    final current = state.valueOrNull;
    if (current == null || current.isSending) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMessage = KutloMessageModel(
      role: KutloRole.user,
      content: trimmed,
      createdAt: DateTime.now(),
    );

    final withUserMessage = current.messages + [userMessage];

    // Optimistically append user message and set loading.
    state = AsyncData(
      current.copyWith(
        messages: withUserMessage,
        isSending: true,
        clearError: true,
      ),
    );

    try {
      final reply = await ref
          .read(kutloRepositoryProvider)
          .sendMessage(
            history: withUserMessage,
            context: current.context,
          );

      final assistantMessage = KutloMessageModel(
        role: KutloRole.assistant,
        content: reply,
        createdAt: DateTime.now(),
      );

      state = AsyncData(
        current.copyWith(
          messages: withUserMessage + [assistantMessage],
          isSending: false,
          clearError: true,
        ),
      );
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          messages: withUserMessage,
          isSending: false,
          sendError:
              e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  /// Clears the conversation history, keeping the context loaded.
  void clearConversation() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      KutloUiState(context: current.context, messages: const []),
    );
  }
}

// Provider 

final kutloViewModelProvider =
    AsyncNotifierProvider.autoDispose<KutloViewModel, KutloUiState>(
  KutloViewModel.new,
);