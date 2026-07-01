import '../../domain/entities/notificacion_entity.dart';

class WsMensajeModel {
  final TipoNotificacion tipo;
  final String? descripcion;
  final String? fecha;
  final int? id;
  final String? tipoAlerta;
  final int? bloqueId;
  final String? mensaje;

  const WsMensajeModel({
    required this.tipo,
    this.descripcion,
    this.fecha,
    this.id,
    this.tipoAlerta,
    this.bloqueId,
    this.mensaje,
  });

  factory WsMensajeModel.fromJson(Map<String, dynamic> json) {
    final raw = json['tipo'] as String? ?? '';
    final tipo = TipoNotificacion.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => TipoNotificacion.desconocido,
    );
    return WsMensajeModel(
      tipo:        tipo,
      descripcion: json['descripcion'] as String?,
      fecha:       json['fecha']       as String?,
      id:          json['id']          as int?,
      tipoAlerta:  json['tipo_alerta'] as String?,
      bloqueId:    json['bloque_id']   as int?,
      mensaje:     json['mensaje']     as String?,
    );
  }

  NotificacionEntity toEntity() => NotificacionEntity(
        tipo:        tipo,
        descripcion: descripcion,
        fecha:       fecha,
        id:          id,
        tipoAlerta:  tipoAlerta,
        bloqueId:    bloqueId,
        mensaje:     mensaje,
      );
}
