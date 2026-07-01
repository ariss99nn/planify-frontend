import 'chat_message.dart';

class Conversation {
  final List<ChatMessage> messages;

  const Conversation({this.messages = const []});

  Conversation addMessage(ChatMessage message) =>
      Conversation(messages: [...messages, message]);

  List<Map<String, String>> toHistorialApi() => messages
      .map((m) => {
            'role': m.role == MessageRole.user ? 'user' : 'assistant',
            'content': m.content,
          })
      .toList();
}
