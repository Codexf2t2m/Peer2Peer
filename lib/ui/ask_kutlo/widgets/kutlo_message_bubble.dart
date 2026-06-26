
// Renders a single message in the conversation.
// User messages are right-aligned; assistant (Kutlo) messages left-aligned.
// Pure render widget — no provider access.

import 'package:flutter/material.dart';

import '../../../data/models/kutlo_message_model.dart';

class KutloMessageBubble extends StatelessWidget {
  const KutloMessageBubble({
    super.key,
    required this.message,
  });

  final KutloMessageModel message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _KutloAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF0038FF)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color:
                      isUser ? Colors.white : const Color(0xFF1E1E1E),
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _KutloAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF0038FF).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.chat_bubble_outline,
          color: Color(0xFF0038FF),
          size: 16,
        ),
      ),
    );
  }
}

/// Typing indicator shown while Kutlo is generating a response.
class KutloTypingIndicator extends StatefulWidget {
  const KutloTypingIndicator({super.key});

  @override
  State<KutloTypingIndicator> createState() => _KutloTypingIndicatorState();
}

class _KutloTypingIndicatorState
    extends State<KutloTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KutloAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2),
                    child: Opacity(
                      opacity: (i == 0
                              ? _animation.value
                              : i == 1
                                  ? (_animation.value + 0.3)
                                      .clamp(0.0, 1.0)
                                  : (_animation.value + 0.6)
                                      .clamp(0.0, 1.0))
                          .clamp(0.2, 1.0),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF9CA3AF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}