import '../../../core/network/api_client.dart';
import '../domain/conversation.dart';
import '../domain/messages_repository.dart';
import 'conversation_dto.dart';

/// [MessagesRepository] against the proposed Epic E paths.
class ApiMessagesRepository implements MessagesRepository {
  const ApiMessagesRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<ConversationSummary>> fetchConversations() async {
    final page = await _client.getList<ConversationSummary>(
      '/conversations',
      conversationSummaryFromJson,
    );
    return page.items;
  }

  @override
  Future<ConversationDetail> fetchConversation(String conversationId) async =>
      conversationDetailFromJson(
        await _client.getObject('/conversations/$conversationId'),
      );

  @override
  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    final page = await _client.getList<ChatMessage>(
      '/conversations/$conversationId/messages',
      chatMessageFromJson,
    );
    return page.items;
  }

  @override
  Future<ChatMessage> sendText(String conversationId, String body) async =>
      chatMessageFromJson(
        await _client.post(
          '/conversations/$conversationId/messages',
          body: {'kind': 'text', 'body': body.trim()},
        ),
      );

  @override
  Future<void> hideMessage(String messageId) =>
      _client.post('/messages/$messageId/hide');

  @override
  Future<void> dismissReport(String reportId) =>
      _client.post('/message-reports/$reportId/dismiss');
}
