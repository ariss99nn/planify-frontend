import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/notificacion_entity.dart';
import '../../domain/repositories/notificaciones_repository.dart';
import '../../domain/usecases/watch_notificaciones_usecase.dart';

class NotificacionesProvider extends ChangeNotifier {
  final NotificacionesRepository _repository;
  late final WatchNotificacionesUseCase _watchUseCase;
  StreamSubscription<NotificacionEntity>? _sub;

  final List<NotificacionEntity> _mensajes = [];
  int _noLeidas = 0;
  String? _ultimoError;
  bool _conectado = false;
  NotificacionEntity? _ultimoMensaje;

  List<NotificacionEntity> get mensajes     => List.unmodifiable(_mensajes);
  int                       get noLeidas    => _noLeidas;
  String?                   get ultimoError => _ultimoError;
  bool                      get conectado   => _conectado;
  NotificacionEntity?       get ultimoMensaje => _ultimoMensaje;

  NotificacionesProvider({required NotificacionesRepository repository})
      : _repository = repository {
    _watchUseCase = WatchNotificacionesUseCase(_repository);
    _init();
  }

  void _init() {
    _repository.connect();
    _sub = _watchUseCase().listen(
      _onMensaje,
      onError: (Object e) {
        _ultimoError = e.toString();
        _conectado   = false;
        notifyListeners();
      },
    );
  }

  void reconnect(String newToken) {
    _sub?.cancel();
    _repository.reconnect(newToken);
    _conectado = false;
    _sub = _watchUseCase().listen(
      _onMensaje,
      onError: (Object e) {
        _ultimoError = e.toString();
        _conectado   = false;
        notifyListeners();
      },
    );
    notifyListeners();
  }

  void _onMensaje(NotificacionEntity msg) {
    switch (msg.tipo) {
      case TipoNotificacion.conexion:
        _conectado   = true;
        _ultimoError = null;
      case TipoNotificacion.alerta_nueva:
      case TipoNotificacion.conflicto_horario:
        _mensajes.insert(0, msg);
        _noLeidas++;
        _ultimoMensaje = msg;
      case TipoNotificacion.pong:
      case TipoNotificacion.desconocido:
        break;
    }
    notifyListeners();
  }

  void marcarTodasLeidas() {
    _noLeidas = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _repository.dispose();
    super.dispose();
  }
}
