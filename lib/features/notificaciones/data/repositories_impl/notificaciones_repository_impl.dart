import 'dart:async';
import '../../domain/entities/notificacion_entity.dart';
import '../../domain/repositories/notificaciones_repository.dart';
import '../datasources/ws_alertas_datasource.dart';

class NotificacionesRepositoryImpl implements NotificacionesRepository {
  WsAlertasDataSource _datasource;
  final String _baseWsUrl;

  NotificacionesRepositoryImpl({
    required String token,
    required String baseWsUrl,
  })  : _baseWsUrl = baseWsUrl,
        _datasource = WsAlertasDataSource(token: token, baseWsUrl: baseWsUrl);

  @override
  Stream<NotificacionEntity> get mensajes =>
      _datasource.mensajes.map((m) => m.toEntity());

  @override
  void connect() => _datasource.connect();

  @override
  void reconnect(String newToken) {
    _datasource.dispose();
    _datasource = WsAlertasDataSource(token: newToken, baseWsUrl: _baseWsUrl);
    _datasource.connect();
  }

  @override
  void dispose() => _datasource.dispose();
}
