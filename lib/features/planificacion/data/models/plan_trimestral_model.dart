// lib/features/planificacion/data/models/plan_trimestral_model.dart

import '../../domain/entities/plan_trimestral_entity.dart';

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

// ─── PlanTrimestralModel ──────────────────────────────────────────────────────

class PlanTrimestralModel {
  final int        id;
  final int        fichaId;
  final String     fichaCodigo;
  final String     programaNombre;
  final int        trimestre;
  final DateTime   fechaInicio;
  final DateTime   fechaFin;
  final EstadoPlan estado;
  final String     estadoDisplay;
  final int?       aprobadoPorId;
  final String?    aprobadoPorNombre;
  final DateTime?  fechaAprobacion;
  final double     totalHorasPlanificadas;
  final double     totalHorasEjecutadas;
  final double     porcentajeAvance;

  const PlanTrimestralModel({
    required this.id,
    required this.fichaId,
    required this.fichaCodigo,
    required this.programaNombre,
    required this.trimestre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.estadoDisplay,
    this.aprobadoPorId,
    this.aprobadoPorNombre,
    this.fechaAprobacion,
    required this.totalHorasPlanificadas,
    required this.totalHorasEjecutadas,
    required this.porcentajeAvance,
  });

  factory PlanTrimestralModel.fromJson(Map<String, dynamic> j) =>
      PlanTrimestralModel(
        id:                     j['id'] as int,
        fichaId:                j['ficha'] as int,
        fichaCodigo:            j['ficha_codigo'] as String? ?? '',
        programaNombre:         j['programa_nombre'] as String? ?? '',
        trimestre:              j['trimestre'] as int,
        fechaInicio:            DateTime.parse(j['fecha_inicio'] as String),
        fechaFin:               DateTime.parse(j['fecha_fin'] as String),
        estado:                 EstadoPlan.fromString(j['estado'] as String),
        estadoDisplay:          j['estado_display'] as String? ?? '',
        aprobadoPorId:          j['aprobado_por'] as int?,
        aprobadoPorNombre:      j['aprobado_por_nombre'] as String?,
        fechaAprobacion:        j['fecha_aprobacion'] != null
            ? DateTime.parse(j['fecha_aprobacion'] as String)
            : null,
        totalHorasPlanificadas: _toDouble(j['total_horas_planificadas']),
        totalHorasEjecutadas:   _toDouble(j['total_horas_ejecutadas']),
        porcentajeAvance:       _toDouble(j['porcentaje_avance']),
      );

  PlanTrimestral toEntity() => PlanTrimestral(
        id:                     id,
        fichaId:                fichaId,
        fichaCodigo:            fichaCodigo,
        programaNombre:         programaNombre,
        trimestre:              trimestre,
        fechaInicio:            fechaInicio,
        fechaFin:               fechaFin,
        estado:                 estado,
        estadoDisplay:          estadoDisplay,
        aprobadoPorId:          aprobadoPorId,
        aprobadoPorNombre:      aprobadoPorNombre,
        fechaAprobacion:        fechaAprobacion,
        totalHorasPlanificadas: totalHorasPlanificadas,
        totalHorasEjecutadas:   totalHorasEjecutadas,
        porcentajeAvance:       porcentajeAvance,
      );
}

// ─── ItemPlanModel ────────────────────────────────────────────────────────────

class ItemPlanModel {
  final int     id;
  final int     planId;
  final int     competenciaId;
  final String  competenciaCodigo;
  final String  competenciaNombre;
  final String  competenciaTipo;
  final int?    docenteId;
  final String? docenteNombre;
  final int     horasAsignadas;
  final double  horasEjecutadas;
  final double  horasRestantes;
  final double  porcentajeAvance;
  final int     orden;
  final bool    completado;

  const ItemPlanModel({
    required this.id,
    required this.planId,
    required this.competenciaId,
    required this.competenciaCodigo,
    required this.competenciaNombre,
    required this.competenciaTipo,
    this.docenteId,
    this.docenteNombre,
    required this.horasAsignadas,
    required this.horasEjecutadas,
    required this.horasRestantes,
    required this.porcentajeAvance,
    required this.orden,
    required this.completado,
  });

  factory ItemPlanModel.fromJson(Map<String, dynamic> j) => ItemPlanModel(
        id:                j['id'] as int,
        planId:            j['plan'] as int,
        competenciaId:     j['competencia'] as int,
        competenciaCodigo: j['competencia_codigo'] as String? ?? '',
        competenciaNombre: j['competencia_nombre'] as String? ?? '',
        competenciaTipo:   j['competencia_tipo'] as String? ?? '',
        docenteId:         j['docente'] as int?,
        docenteNombre:     j['docente_nombre'] as String?,
        horasAsignadas:    j['horas_asignadas'] as int,
        horasEjecutadas:   _toDouble(j['horas_ejecutadas']),
        horasRestantes:    _toDouble(j['horas_restantes']),
        porcentajeAvance:  _toDouble(j['porcentaje_avance']),
        orden:             j['orden'] as int,
        completado:        j['completado'] as bool? ?? false,
      );

  ItemPlan toEntity() => ItemPlan(
        id:                id,
        planId:            planId,
        competenciaId:     competenciaId,
        competenciaCodigo: competenciaCodigo,
        competenciaNombre: competenciaNombre,
        competenciaTipo:   competenciaTipo,
        docenteId:         docenteId,
        docenteNombre:     docenteNombre,
        horasAsignadas:    horasAsignadas,
        horasEjecutadas:   horasEjecutadas,
        horasRestantes:    horasRestantes,
        porcentajeAvance:  porcentajeAvance,
        orden:             orden,
        completado:        completado,
      );
}

// ─── PlanTrimestralDetalleModel ───────────────────────────────────────────────

class PlanTrimestralDetalleModel extends PlanTrimestralModel {
  final String           motivoRechazo;
  final List<ItemPlanModel> items;
  final DateTime         createdAt;
  final DateTime         updatedAt;

  const PlanTrimestralDetalleModel({
    required super.id,
    required super.fichaId,
    required super.fichaCodigo,
    required super.programaNombre,
    required super.trimestre,
    required super.fechaInicio,
    required super.fechaFin,
    required super.estado,
    required super.estadoDisplay,
    super.aprobadoPorId,
    super.aprobadoPorNombre,
    super.fechaAprobacion,
    required super.totalHorasPlanificadas,
    required super.totalHorasEjecutadas,
    required super.porcentajeAvance,
    required this.motivoRechazo,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlanTrimestralDetalleModel.fromJson(Map<String, dynamic> j) {
    final base = PlanTrimestralModel.fromJson(j);
    return PlanTrimestralDetalleModel(
      id:                     base.id,
      fichaId:                base.fichaId,
      fichaCodigo:            base.fichaCodigo,
      programaNombre:         base.programaNombre,
      trimestre:              base.trimestre,
      fechaInicio:            base.fechaInicio,
      fechaFin:               base.fechaFin,
      estado:                 base.estado,
      estadoDisplay:          base.estadoDisplay,
      aprobadoPorId:          base.aprobadoPorId,
      aprobadoPorNombre:      base.aprobadoPorNombre,
      fechaAprobacion:        base.fechaAprobacion,
      totalHorasPlanificadas: base.totalHorasPlanificadas,
      totalHorasEjecutadas:   base.totalHorasEjecutadas,
      porcentajeAvance:       base.porcentajeAvance,
      motivoRechazo:          j['motivo_rechazo'] as String? ?? '',
      items:                  (j['items'] as List<dynamic>? ?? [])
          .map((e) => ItemPlanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt:              DateTime.parse(j['created_at'] as String),
      updatedAt:              DateTime.parse(j['updated_at'] as String),
    );
  }

  PlanTrimestralDetalle toDetalleEntity() => PlanTrimestralDetalle(
        id:                     id,
        fichaId:                fichaId,
        fichaCodigo:            fichaCodigo,
        programaNombre:         programaNombre,
        trimestre:              trimestre,
        fechaInicio:            fechaInicio,
        fechaFin:               fechaFin,
        estado:                 estado,
        estadoDisplay:          estadoDisplay,
        aprobadoPorId:          aprobadoPorId,
        aprobadoPorNombre:      aprobadoPorNombre,
        fechaAprobacion:        fechaAprobacion,
        totalHorasPlanificadas: totalHorasPlanificadas,
        totalHorasEjecutadas:   totalHorasEjecutadas,
        porcentajeAvance:       porcentajeAvance,
        motivoRechazo:          motivoRechazo,
        items:                  items.map((i) => i.toEntity()).toList(),
        createdAt:              createdAt,
        updatedAt:              updatedAt,
      );
}

// ─── BloqueCompetenciaModel ───────────────────────────────────────────────────

class BloqueCompetenciaModel {
  final int    id;
  final int    bloqueId;
  final int    itemPlanId;
  final String competenciaCodigo;
  final String competenciaNombre;
  final String bloqueDia;
  final String bloqueHoraInicio;
  final String bloqueHoraFin;
  final double horasEjecutadas;
  final double horasRestantesItem;
  final String observaciones;

  const BloqueCompetenciaModel({
    required this.id,
    required this.bloqueId,
    required this.itemPlanId,
    required this.competenciaCodigo,
    required this.competenciaNombre,
    required this.bloqueDia,
    required this.bloqueHoraInicio,
    required this.bloqueHoraFin,
    required this.horasEjecutadas,
    required this.horasRestantesItem,
    required this.observaciones,
  });

  factory BloqueCompetenciaModel.fromJson(Map<String, dynamic> j) =>
      BloqueCompetenciaModel(
        id:                 j['id'] as int,
        bloqueId:           j['bloque'] as int,
        itemPlanId:         j['item_plan'] as int,
        competenciaCodigo:  j['competencia_codigo'] as String? ?? '',
        competenciaNombre:  j['competencia_nombre'] as String? ?? '',
        bloqueDia:          j['bloque_dia'] as String? ?? '',
        bloqueHoraInicio:   j['bloque_hora_inicio'] as String? ?? '',
        bloqueHoraFin:      j['bloque_hora_fin'] as String? ?? '',
        horasEjecutadas:    _toDouble(j['horas_ejecutadas']),
        horasRestantesItem: _toDouble(j['horas_restantes_item']),
        observaciones:      j['observaciones'] as String? ?? '',
      );

  BloqueCompetencia toEntity() => BloqueCompetencia(
        id:                 id,
        bloqueId:           bloqueId,
        itemPlanId:         itemPlanId,
        competenciaCodigo:  competenciaCodigo,
        competenciaNombre:  competenciaNombre,
        bloqueDia:          bloqueDia,
        bloqueHoraInicio:   bloqueHoraInicio,
        bloqueHoraFin:      bloqueHoraFin,
        horasEjecutadas:    horasEjecutadas,
        horasRestantesItem: horasRestantesItem,
        observaciones:      observaciones,
      );
}

// ─── ResultadoGenerarHorarioModel ─────────────────────────────────────────────

class ConflictoHorarioModel {
  final String  item;
  final String? dia;
  final String? hora;
  final String  error;

  const ConflictoHorarioModel({
    required this.item,
    this.dia,
    this.hora,
    required this.error,
  });

  factory ConflictoHorarioModel.fromJson(Map<String, dynamic> j) =>
      ConflictoHorarioModel(
        item:  j['item'] as String? ?? '',
        dia:   j['dia'] as String?,
        hora:  j['hora'] as String?,
        error: j['error'] as String? ?? '',
      );

  ConflictoHorario toEntity() =>
      ConflictoHorario(item: item, dia: dia, hora: hora, error: error);
}

class ResultadoGenerarHorarioModel {
  final int                       bloquesCreados;
  final bool                      completado;
  final List<ConflictoHorarioModel> conflictos;

  const ResultadoGenerarHorarioModel({
    required this.bloquesCreados,
    required this.completado,
    required this.conflictos,
  });

  factory ResultadoGenerarHorarioModel.fromJson(Map<String, dynamic> j) =>
      ResultadoGenerarHorarioModel(
        bloquesCreados: j['bloques_creados'] as int? ?? 0,
        completado:     j['completado'] as bool? ?? false,
        conflictos:     (j['conflictos'] as List<dynamic>? ?? [])
            .map((e) => ConflictoHorarioModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  ResultadoGenerarHorario toEntity() => ResultadoGenerarHorario(
        bloquesCreados: bloquesCreados,
        completado:     completado,
        conflictos:     conflictos.map((c) => c.toEntity()).toList(),
      );
}
