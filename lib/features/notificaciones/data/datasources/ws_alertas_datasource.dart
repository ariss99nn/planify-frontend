import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/ws_mensaje_model.dart';

class WsAlertasDataSource {
  final String token;
  final String baseWsUrl;

  WsAlertasDataSource({
    required this.token,
    required this.baseWsUrl,
  });

  WebSocketChannel? _channel;
  final _controller = StreamController<WsMensajeModel>.broadcast();
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  bool _disposed = false;
  int _retryCount = 0;

  Stream<WsMensajeModel> get mensajes => _controller.stream;

  void connect() {
    if (_disposed) return;
    if (token.isEmpty) {
      debugPrint('WS: token vacío, no se conecta');
      return;
    }

    try {
      final uri = Uri.parse('$baseWsUrl/ws/alertas/?token=$token');
      debugPrint('WS conectando: $uri');

      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _send({'tipo': 'ping'}),
      );
    } catch (e) {
      debugPrint('WS error al conectar: $e');
      _scheduleReconnect();
    }
  }

  void _onData(dynamic raw) {
    if (_disposed) return;
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      final msg  = WsMensajeModel.fromJson(json);
      if (msg.tipo.name != 'desconocido') _retryCount = 0;
      _controller.add(msg);
    } catch (_) {}
  }

  void _onError(Object e) {
    if (_disposed) return;
    _controller.addError(e);
    _scheduleReconnect();
  }

  void _onDone() {
    _pingTimer?.cancel();
    if (!_disposed) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    final delay = Duration(seconds: min(pow(2, _retryCount).toInt(), 60));
    _retryCount++;
    debugPrint('WS reconectando en ${delay.inSeconds}s (intento $_retryCount)');
    _reconnectTimer = Timer(delay, connect);
  }

  void _send(Map<String, dynamic> data) {
    try {
      _channel?.sink.add(jsonEncode(data));
    } catch (_) {}
  }

  void dispose() {
    _disposed = true;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _controller.close();
  }
}
