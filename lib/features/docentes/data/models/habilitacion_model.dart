// lib/features/docentes/data/models/habilitacion_model.dart

import '../../domain/entities/habilitacion_entity.dart';

class HabilitacionModel extends HabilitacionEntity {
  const HabilitacionModel({
    required super.id,
    required super.docenteId,
    required super.docenteNombre,
    required super.nivel,
    required super.nivelDisplay,
    required super.moduloId,
    required super.moduloNombre,
    required super.asignaturaId,
    required super.asignaturaNombre,
    required super.activo,
    required super.fechaDesde,
    required super.fechaHasta,
    required super.observaciones,
  });

  factory HabilitacionModel.fromJson(Map<String, dynamic> json) {
    return HabilitacionModel(
      id:              json['id']               as int,
      docenteId:       json['docente']          as int,
      docenteNombre:   json['docente_nombre']   as String? ?? '',
      nivel:           HabilitacionNivel.fromValue(json['nivel'] as String),
      nivelDisplay:    json['nivel_display']    as String? ?? '',
      moduloId:        json['modulo']           as int?,
      moduloNombre:    json['modulo_nombre']    as String?,
      asignaturaId:    json['asignatura']       as int?,
      asignaturaNombre: json['asignatura_nombre'] as String?,
      activo:          json['activo']           as bool,
      fechaDesde:      DateTime.parse(json['fecha_desde'] as String),
      fechaHasta:      json['fecha_hasta'] != null
          ? DateTime.parse(json['fecha_hasta'] as String)
          : null,
      observaciones:   json['observaciones']   as String? ?? '',
    );
  }
}
