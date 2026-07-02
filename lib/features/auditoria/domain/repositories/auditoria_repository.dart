import '../entities/auditoria_entity.dart';

abstract class AuditoriaRepository {
  /// Retorna la página solicitada del log de auditoría.
  /// [metodo]: filtro opcional (POST/PATCH/PUT/DELETE).
  /// [path]: filtro opcional por endpoint (búsqueda parcial).
  /// [usuarioId]: filtro opcional por autor del cambio.
  Future<AuditLogPageEntity> getAuditLog({
    int page = 1,
    String? metodo,
    String? path,
    int? usuarioId,
  });
}

class AuditLogPageEntity {
  final List<AuditLogEntity> items;
  final int total;
  final bool hasNext;

  const AuditLogPageEntity({
    required this.items,
    required this.total,
    required this.hasNext,
  });
}
