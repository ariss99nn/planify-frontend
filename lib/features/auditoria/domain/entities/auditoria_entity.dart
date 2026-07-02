class AuditLogEntity {
  final int id;
  final String metodo;
  final String path;
  final int statusCode;
  final double duracionMs;
  final String? ip;
  final DateTime fecha;
  final int? usuarioId;
  final String? usuarioEmail;

  const AuditLogEntity({
    required this.id,
    required this.metodo,
    required this.path,
    required this.statusCode,
    required this.duracionMs,
    required this.fecha,
    this.ip,
    this.usuarioId,
    this.usuarioEmail,
  });

  bool get fueExitoso => statusCode < 400;
}
