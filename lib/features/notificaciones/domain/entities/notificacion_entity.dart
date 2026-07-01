enum TipoNotificacion { alerta_nueva, conflicto_horario, conexion, pong, desconocido }

class NotificacionEntity {
  final TipoNotificacion tipo;
  final String? descripcion;
  final String? fecha;
  final int? id;
  final String? tipoAlerta;
  final int? bloqueId;
  final String? mensaje;

  const NotificacionEntity({
    required this.tipo,
    this.descripcion,
    this.fecha,
    this.id,
    this.tipoAlerta,
    this.bloqueId,
    this.mensaje,
  });
}
