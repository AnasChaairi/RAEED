import 'conversation.dart';

/// Reads and acts on conversations with executive oversight.
///
/// Every path here is proposed by the executive screen specs
/// (`specs/06-mobile-app-spec.md`, EXEC-M-03) for Epic E and is not yet in
/// `specs/04-api/openapi.yaml`. Until the backend lands, the screens show the
/// ordinary error state rather than invented threads.
abstract interface class MessagesRepository {
  /// Every conversation the caller may see — as a member or by oversight.
  Future<List<ConversationSummary>> fetchConversations();

  Future<ConversationDetail> fetchConversation(String conversationId);

  /// The thread, oldest first.
  ///
  /// Reading a thread the caller is not a member of is audit-logged
  /// server-side (`MSG-08`); the screen says so before the messages render.
  Future<List<ChatMessage>> fetchMessages(String conversationId);

  Future<ChatMessage> sendText(String conversationId, String body);

  /// Hides a message. Reversible, logged, never a deletion.
  Future<void> hideMessage(String messageId);

  /// Closes a report without hiding the message.
  Future<void> dismissReport(String reportId);
}
