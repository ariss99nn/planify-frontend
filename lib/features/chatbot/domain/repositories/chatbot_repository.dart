import '../entities/chat_message.dart';
import '../entities/conversation.dart';

abstract class ChatbotRepository {
  Future<ChatMessage> sendMessage({
    required String question,
    required Conversation conversation,
    required String token,
  });
}
