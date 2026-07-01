import '../entities/chat_message.dart';
import '../entities/conversation.dart';
import '../repositories/chatbot_repository.dart';

class SendMessageUsecase {
  final ChatbotRepository _repository;

  const SendMessageUsecase(this._repository);

  Future<ChatMessage> call({
    required String question,
    required Conversation conversation,
    required String token,
  }) =>
      _repository.sendMessage(
        question: question,
        conversation: conversation,
        token: token,
      );
}
