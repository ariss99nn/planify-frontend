import '../../domain/entities/novedad_entity.dart';

class NovedadModel extends NovedadEntity {
  const NovedadModel({
    required super.id,
    required super.tipo,
    required super.tipoDisplay,
    required super.prioridad,
    required super.prioridadDisplay,
    required super.titulo,
    required super.descripcion,
    required super.generadaPorSistema,
    super.generadaPor,
    required super.atendida,
    super.atendidaPor,
    super.atendidaPorNombre,
    super.fechaAtencion,
    required super.notaAtencion,
    required super.fechaGeneracion,
    super.fechaExpiracion,
    required super.estaVigente,
  });

  factory NovedadModel.fromJson(Map<String, dynamic> json) {
    return NovedadModel(
      id: json['id'] as int,
      tipo: NovedadTipoX.fromValue(json['tipo'] as String),
      tipoDisplay: json['tipo_display'] as String? ?? '',
      prioridad: NovedadPrioridadX.fromValue(json['prioridad'] as int),
      prioridadDisplay: json['prioridad_display'] as String? ?? '',
      titulo: json['titulo'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      generadaPorSistema: json['generada_por_sistema'] as bool? ?? true,
      generadaPor: json['generada_por'] as int?,
      atendida: json['atendida'] as bool? ?? false,
      atendidaPor: json['atendida_por'] as int?,
      atendidaPorNombre: json['atendida_por_nombre'] as String?,
      fechaAtencion: _parseDate(json['fecha_atencion']),
      notaAtencion: json['nota_atencion'] as String? ?? '',
      fechaGeneracion: _parseDate(json['fecha_generacion']) ?? DateTime.now(),
      fechaExpiracion: _parseDate(json['fecha_expiracion']),
      estaVigente: json['esta_vigente'] as bool? ?? true,
    );
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw as String);
  }
}
