import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.content,
    required super.role,
    required super.timestamp,
  });

  factory ChatMessageModel.userMessage(String content) => ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );

  factory ChatMessageModel.assistantMessage(String content) => ChatMessageModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_a',
        content: content,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );
}
