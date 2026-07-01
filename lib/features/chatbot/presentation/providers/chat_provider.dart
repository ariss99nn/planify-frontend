import 'package:flutter/material.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/clear_conversation_usecase.dart';
import '../../data/models/chat_message_model.dart';

enum ChatStatus { idle, loading, error }

class ChatProvider extends ChangeNotifier {
  final SendMessageUsecase _sendMessage;
  final ClearConversationUsecase _clearConversation;

  String _token = '';
  Conversation _conversation = const Conversation();
  ChatStatus _status = ChatStatus.idle;
  String? _errorMessage;

  ChatProvider({
    required SendMessageUsecase sendMessage,
    required ClearConversationUsecase clearConversation,
  })  : _sendMessage = sendMessage,
        _clearConversation = clearConversation;

  List<ChatMessage> get messages => _conversation.messages;
  ChatStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ChatStatus.loading;

  void updateToken(String? token) {
    _token = token ?? '';
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty || isLoading) return;

    if (_token.isEmpty) {
      _errorMessage = 'Sin sesión activa.';
      _status = ChatStatus.error;
      notifyListeners();
      return;
    }

    final userMessage = ChatMessageModel.userMessage(text.trim());
    _conversation = _conversation.addMessage(userMessage);
    _status = ChatStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final historialPrevio = Conversation(
      messages: _conversation.messages
          .where((m) => m.id != userMessage.id)
          .toList(),
    );

    try {
      final response = await _sendMessage(
        question: text.trim(),
        conversation: historialPrevio,
        token: _token,
      );
      _conversation = _conversation.addMessage(response);
      _status = ChatStatus.idle;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = ChatStatus.error;
    }

    notifyListeners();
  }

  void clear() {
    _conversation = _clearConversation();
    _status = ChatStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
