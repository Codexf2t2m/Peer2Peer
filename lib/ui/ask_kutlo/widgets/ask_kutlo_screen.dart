
// UC: Financial Guidance, Lending Suggestions, Run Credit Assessment,
//     Receive Overdraft Protection, Explain Limit Changes
//
// Architecture
// ────────────
// • Watches [kutloViewModelProvider] — one AsyncValue<KutloUiState>.
// • Local controller + focusNode are the only StatefulWidget concern.
// • All conversation logic (send, clear) lives in KutloViewModel.
// • Suggestion chips fill the input field; the user still taps Send.
// • Auto-scrolls to the latest message on each state change.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_card.dart';
import '../../../../ui/widgets/app_back_button.dart';
import '../view_models/kutlo_view_model.dart';
import 'kutlo_empty_state.dart';
import 'kutlo_input_bar.dart';
import 'kutlo_message_bubble.dart';
import 'kutlo_suggestion_chips.dart';

class AskKutloScreen extends ConsumerStatefulWidget {
  const AskKutloScreen({super.key});

  @override
  ConsumerState<AskKutloScreen> createState() =>
      _AskKutloScreenState();
}

class _AskKutloScreenState
    extends ConsumerState<AskKutloScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _focusNode.unfocus();
    ref.read(kutloViewModelProvider.notifier).send(text);
    _scrollToBottom();
  }

  void _fillSuggestion(String prompt) {
    _controller.text = prompt;
    _focusNode.requestFocus();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(kutloViewModelProvider);

    // Auto-scroll when new messages arrive.
    ref.listen(kutloViewModelProvider, (_, next) {
      if (next.valueOrNull?.messages.isNotEmpty == true) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop()
            ? const AppBackButton()
            : null,
        titleSpacing: 16,
        title: Text(
          'Ask Kutlo',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          // Clear conversation
          uiState.valueOrNull?.hasMessages == true
              ? IconButton(
                  tooltip: 'Clear conversation',
                  onPressed: () => ref
                      .read(kutloViewModelProvider.notifier)
                      .clearConversation(),
                  icon: const Icon(Icons.refresh_rounded, size: 22),
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: uiState.when(
        // Context loading 
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),

        // Context load error 
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: AppCard(
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
              ],
            ),
          ),
        ),

        // Conversation 
        data: (state) => Column(
          children: [
            // Messages area 
            Expanded(
              child: state.hasMessages
                  ? ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(
                          16, 12, 16, 8),
                      itemCount: state.messages.length +
                          (state.isSending ? 1 : 0) +
                          (state.hasError ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Error banner after messages
                        if (state.hasError &&
                            index == state.messages.length) {
                          return _ErrorBanner(
                              message: state.sendError!);
                        }
                        // Typing indicator
                        if (state.isSending &&
                            index == state.messages.length) {
                          return const KutloTypingIndicator();
                        }
                        return KutloMessageBubble(
                          message: state.messages[index],
                        );
                      },
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: KutloEmptyState(
                            userName: state.context.userName,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Suggestions shown only before first message
                        KutloSuggestionChips(
                          onSuggestionTap: _fillSuggestion,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
            ),

            // nput bar 
            KutloInputBar(
              controller: _controller,
              focusNode: _focusNode,
              onSend: _send,
              isSending: state.isSending,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: Color(0xFFEF4444), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: Color(0xFFEF4444), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}