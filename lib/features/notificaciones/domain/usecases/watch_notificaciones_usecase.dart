import '../entities/notificacion_entity.dart';
import '../repositories/notificaciones_repository.dart';

class WatchNotificacionesUseCase {
  final NotificacionesRepository repository;

  const WatchNotificacionesUseCase(this.repository);

  Stream<NotificacionEntity> call() => repository.mensajes;
}
