
// Represents one message in a Kutlo AI conversation turn.
//
// Kutlo conversations are stateless on the server — the full history is
// sent with each request.  This model represents a single turn and is
// used both to build the request payload and to render the chat UI.

/// Who authored this message in the conversation.
enum KutloRole { user, assistant }

/// A single message in a Kutlo AI conversation.
class KutloMessageModel {
  const KutloMessageModel({
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final KutloRole role;
  final String content;
  final DateTime createdAt;

  bool get isUser => role == KutloRole.user;
  bool get isAssistant => role == KutloRole.assistant;

  /// Serialises to the format expected by the Edge Function / AI API.
  Map<String, String> toApiMessage() => {
        'role': role == KutloRole.user ? 'user' : 'assistant',
        'content': content,
      };

  @override
  String toString() =>
      'KutloMessage(${role.name}: ${content.substring(0, content.length.clamp(0, 60))}...)';
}