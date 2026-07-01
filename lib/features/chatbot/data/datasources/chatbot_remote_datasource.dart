import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message_model.dart';
import '../../domain/entities/conversation.dart';

abstract class ChatbotRemoteDatasource {
  Future<ChatMessageModel> sendMessage({
    required String question,
    required Conversation conversation,
    required String token,
  });
}

class ChatbotRemoteDatasourceImpl implements ChatbotRemoteDatasource {
  final http.Client _client;
  final String _baseUrl;

  const ChatbotRemoteDatasourceImpl({
    required http.Client client,
    required String baseUrl,
  })  : _client = client,
        _baseUrl = baseUrl;

  @override
  Future<ChatMessageModel> sendMessage({
    required String question,
    required Conversation conversation,
    required String token,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/chatbot/chat/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'pregunta': question,
        'historial': conversation.toHistorialApi(),
      }),
    );

    if (response.statusCode == 200) {
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ChatMessageModel.assistantMessage(data['respuesta'] as String);
    }

    if (response.statusCode == 401) {
      throw Exception('Sesión expirada. Vuelve a iniciar sesión.');
    }

    if (response.statusCode == 403) {
      throw Exception('Tu rol no tiene acceso al asistente.');
    }

    if (response.statusCode == 429) {
      throw Exception('Demasiadas solicitudes. Espera un momento.');
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }
}
