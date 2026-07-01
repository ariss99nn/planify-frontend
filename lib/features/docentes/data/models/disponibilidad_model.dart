// lib/features/docentes/data/models/disponibilidad_model.dart

import '../../domain/entities/disponibilidad_entity.dart';

class DisponibilidadModel extends DisponibilidadEntity {
  const DisponibilidadModel({
    required super.id,
    required super.docenteId,
    required super.docenteNombre,
    required super.diaSemana,
    required super.diaDisplay,
    required super.horaInicio,
    required super.horaFin,
    required super.disponible,
    required super.motivo,
    required super.tipoRestriccion,
    required super.tipoRestriccionDisplay,
    super.fechaInicioRestriccion,
    super.fechaFinRestriccion,
  });

  factory DisponibilidadModel.fromJson(Map<String, dynamic> json) {
    return DisponibilidadModel(
      id:                      json['id']                       as int,
      docenteId:               json['docente']                  as int,
      docenteNombre:           json['docente_nombre']           as String? ?? '',
      diaSemana:               json['dia_semana']               as String? ?? '',
      diaDisplay:              json['dia_display']              as String? ?? '',
      horaInicio:              json['hora_inicio']              as String? ?? '',
      horaFin:                 json['hora_fin']                 as String? ?? '',
      disponible:              json['disponible']               as bool?   ?? true,
      motivo:                  json['motivo']                   as String? ?? '',
      tipoRestriccion:         json['tipo_restriccion']         as String? ?? 'PERMANENTE',
      tipoRestriccionDisplay:  json['tipo_restriccion_display'] as String? ?? '',
      fechaInicioRestriccion:  json['fecha_inicio_restriccion'] as String?,
      fechaFinRestriccion:     json['fecha_fin_restriccion']    as String?,
    );
  }
}
