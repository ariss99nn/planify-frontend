import '../../domain/entities/auditoria_entity.dart';

class AuditLogModel {
  final int id;
  final String metodo;
  final String path;
  final int statusCode;
  final double duracionMs;
  final String? ip;
  final DateTime fecha;
  final int? usuario;
  final String? usuarioEmail;

  const AuditLogModel({
    required this.id,
    required this.metodo,
    required this.path,
    required this.statusCode,
    required this.duracionMs,
    required this.fecha,
    this.ip,
    this.usuario,
    this.usuarioEmail,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as int,
      metodo: json['metodo'] as String,
      path: json['path'] as String,
      statusCode: json['status_code'] as int,
      duracionMs: (json['duracion_ms'] as num).toDouble(),
      ip: json['ip'] as String?,
      fecha: DateTime.parse(json['fecha'] as String),
      usuario: json['usuario'] as int?,
      usuarioEmail: json['usuario_email'] as String?,
    );
  }

  AuditLogEntity toEntity() => AuditLogEntity(
        id: id,
        metodo: metodo,
        path: path,
        statusCode: statusCode,
        duracionMs: duracionMs,
        ip: ip,
        fecha: fecha,
        usuarioId: usuario,
        usuarioEmail: usuarioEmail,
      );
}
