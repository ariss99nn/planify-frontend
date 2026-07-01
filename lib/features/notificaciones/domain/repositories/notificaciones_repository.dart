import '../entities/notificacion_entity.dart';

abstract class NotificacionesRepository {
  Stream<NotificacionEntity> get mensajes;
  void connect();
  void reconnect(String newToken);
  void dispose();
}
