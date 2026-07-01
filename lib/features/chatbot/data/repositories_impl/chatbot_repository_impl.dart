import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../datasources/chatbot_remote_datasource.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatbotRemoteDatasource _datasource;

  const ChatbotRepositoryImpl(this._datasource);

  @override
  Future<ChatMessage> sendMessage({
    required String question,
    required Conversation conversation,
    required String token,
  }) =>
      _datasource.sendMessage(
        question: question,
        conversation: conversation,
        token: token,
      );
}
