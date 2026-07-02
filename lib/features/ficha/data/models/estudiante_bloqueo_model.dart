// lib/features/ficha/data/models/estudiante_bloqueo_model.dart

import '../../domain/entities/estudiante_bloqueo_entity.dart';

class EstudianteBloqueoModel {
  final int id;
  final int estudiante;
  final String estudianteNombre;
  final String estudianteEmail;
  final String motivo;
  final String motivoDisplay;
  final String? fichaOrigenCodigo;
  final bool activo;
  final bool vigente;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? desbloqueadoPorNombre;
  final DateTime? fechaDesbloqueo;
  final String observacionDesbloqueo;

  EstudianteBloqueoModel({
    required this.id,
    required this.estudiante,
    required this.estudianteNombre,
    required this.estudianteEmail,
    required this.motivo,
    required this.motivoDisplay,
    this.fichaOrigenCodigo,
    required this.activo,
    required this.vigente,
    required this.fechaInicio,
    required this.fechaFin,
    this.desbloqueadoPorNombre,
    this.fechaDesbloqueo,
    this.observacionDesbloqueo = '',
  });

  factory EstudianteBloqueoModel.fromJson(Map<String, dynamic> json) {
    return EstudianteBloqueoModel(
      id:                     json['id'],
      estudiante:             json['estudiante'],
      estudianteNombre:       json['estudiante_nombre'] ?? '',
      estudianteEmail:        json['estudiante_email'] ?? '',
      motivo:                 json['motivo'] ?? '',
      motivoDisplay:          json['motivo_display'] ?? '',
      fichaOrigenCodigo:      json['ficha_origen_codigo'],
      activo:                 json['activo'] ?? false,
      vigente:                json['vigente'] ?? false,
      fechaInicio:            DateTime.parse(json['fecha_inicio']),
      fechaFin:               DateTime.parse(json['fecha_fin']),
      desbloqueadoPorNombre:  json['desbloqueado_por_nombre'],
      fechaDesbloqueo: json['fecha_desbloqueo'] != null
          ? DateTime.parse(json['fecha_desbloqueo'])
          : null,
      observacionDesbloqueo: json['observacion_desbloqueo'] ?? '',
    );
  }

  EstudianteBloqueoEntity toEntity() => EstudianteBloqueoEntity(
        id: id,
        estudiante: estudiante,
        estudianteNombre: estudianteNombre,
        estudianteEmail: estudianteEmail,
        motivo: motivo,
        motivoDisplay: motivoDisplay,
        fichaOrigenCodigo: fichaOrigenCodigo,
        activo: activo,
        vigente: vigente,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        desbloqueadoPorNombre: desbloqueadoPorNombre,
        fechaDesbloqueo: fechaDesbloqueo,
        observacionDesbloqueo: observacionDesbloqueo,
      );
}
