// lib/features/planificacion/domain/entities/plan_trimestral_entity.dart

// ─── EstadoPlan ───────────────────────────────────────────────────────────────

enum EstadoPlan {
  borrador,
  enRevision,
  aprobado,
  enEjecucion,
  cerrado,
  rechazado;

  static EstadoPlan fromString(String v) {
    switch (v) {
      case 'BORRADOR':     return EstadoPlan.borrador;
      case 'EN_REVISION':  return EstadoPlan.enRevision;
      case 'APROBADO':     return EstadoPlan.aprobado;
      case 'EN_EJECUCION': return EstadoPlan.enEjecucion;
      case 'CERRADO':      return EstadoPlan.cerrado;
      case 'RECHAZADO':    return EstadoPlan.rechazado;
      default:             return EstadoPlan.borrador;
    }
  }

  String toApiString() {
    switch (this) {
      case EstadoPlan.borrador:    return 'BORRADOR';
      case EstadoPlan.enRevision:  return 'EN_REVISION';
      case EstadoPlan.aprobado:    return 'APROBADO';
      case EstadoPlan.enEjecucion: return 'EN_EJECUCION';
      case EstadoPlan.cerrado:     return 'CERRADO';
      case EstadoPlan.rechazado:   return 'RECHAZADO';
    }
  }

  String get label {
    switch (this) {
      case EstadoPlan.borrador:    return 'Borrador';
      case EstadoPlan.enRevision:  return 'En revisión';
      case EstadoPlan.aprobado:    return 'Aprobado';
      case EstadoPlan.enEjecucion: return 'En ejecución';
      case EstadoPlan.cerrado:     return 'Cerrado';
      case EstadoPlan.rechazado:   return 'Rechazado';
    }
  }

  List<EstadoPlan> get transicionesValidas {
    switch (this) {
      case EstadoPlan.borrador:    return [EstadoPlan.enRevision];
      case EstadoPlan.enRevision:  return [EstadoPlan.aprobado, EstadoPlan.rechazado];
      case EstadoPlan.aprobado:    return [EstadoPlan.enEjecucion];
      case EstadoPlan.enEjecucion: return [EstadoPlan.cerrado];
      case EstadoPlan.rechazado:   return [EstadoPlan.borrador];
      case EstadoPlan.cerrado:     return [];
    }
  }

  bool get esEditable =>
      this == EstadoPlan.borrador || this == EstadoPlan.enRevision;
}

// ─── Filtros (value objects) ──────────────────────────────────────────────────

class PlanTrimestralFiltros {
  final int?       ficha;
  final int?       trimestre;
  final EstadoPlan? estado;
  final int?       programa;
  final int?       page;
  final int?       pageSize;

  const PlanTrimestralFiltros({
    this.ficha,
    this.trimestre,
    this.estado,
    this.programa,
    this.page,
    this.pageSize,
  });

  Map<String, String> toQueryParams() => {
    if (ficha     != null) 'ficha':     '$ficha',
    if (trimestre != null) 'trimestre': '$trimestre',
    if (estado    != null) 'estado':    estado!.toApiString(),
    if (programa  != null) 'programa':  '$programa',
    if (page      != null) 'page':      '$page',
    if (pageSize  != null) 'page_size': '$pageSize',
  };
}

class ItemPlanFiltros {
  final int?    plan;
  final int?    docente;
  final bool?   completado;
  final String? tipoCompetencia;
  final int?    page;

  const ItemPlanFiltros({
    this.plan,
    this.docente,
    this.completado,
    this.tipoCompetencia,
    this.page,
  });

  Map<String, String> toQueryParams() => {
    if (plan            != null) 'plan':             '$plan',
    if (docente         != null) 'docente':          '$docente',
    if (completado      != null) 'completado':       '$completado',
    if (tipoCompetencia != null) 'tipo_competencia': tipoCompetencia!,
    if (page            != null) 'page':             '$page',
  };
}

// ─── Entities ─────────────────────────────────────────────────────────────────

class PlanTrimestral {
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

  const PlanTrimestral({
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
}

class PlanTrimestralDetalle extends PlanTrimestral {
  final String       motivoRechazo;
  final List<ItemPlan> items;
  final DateTime     createdAt;
  final DateTime     updatedAt;

  const PlanTrimestralDetalle({
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

  PlanTrimestralDetalle withItems(List<ItemPlan> newItems) =>
      PlanTrimestralDetalle(
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
        items:                  newItems,
        createdAt:              createdAt,
        updatedAt:              updatedAt,
      );
}

class ItemPlan {
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

  const ItemPlan({
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
}

class BloqueCompetencia {
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

  const BloqueCompetencia({
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
}

class ConflictoHorario {
  final String  item;
  final String? dia;
  final String? hora;
  final String  error;

  const ConflictoHorario({
    required this.item,
    this.dia,
    this.hora,
    required this.error,
  });
}

class ResultadoGenerarHorario {
  final int                   bloquesCreados;
  final bool                  completado;
  final List<ConflictoHorario> conflictos;

  const ResultadoGenerarHorario({
    required this.bloquesCreados,
    required this.completado,
    required this.conflictos,
  });
}

// ─── Auto-generación de planes ────────────────────────────────────────────────

class ConflictoAutoGeneracion {
  final String competencia;
  final String motivo;
  final String tipo; // SIN_DOCENTE | SOBRECARGA | VALIDACION | SIN_HORAS

  const ConflictoAutoGeneracion({
    required this.competencia,
    required this.motivo,
    required this.tipo,
  });

  String get tipoLabel {
    switch (tipo) {
      case 'SIN_DOCENTE': return 'Sin docente disponible';
      case 'SOBRECARGA':  return 'Docentes al tope de carga';
      case 'VALIDACION':  return 'No cumple una regla del plan';
      case 'SIN_HORAS':   return 'Sin horas configuradas';
      default:            return 'Requiere revisión';
    }
  }
}

class ReporteAutoGeneracion {
  final int    itemsCreados;
  final List<ConflictoAutoGeneracion> conflictos;
  final bool   requiereRevisionManual;

  const ReporteAutoGeneracion({
    required this.itemsCreados,
    required this.conflictos,
    required this.requiereRevisionManual,
  });
}

class ResultadoAutoGeneracion {
  final PlanTrimestralDetalle plan;
  final ReporteAutoGeneracion reporte;

  const ResultadoAutoGeneracion({required this.plan, required this.reporte});
}

// ─── Exception ────────────────────────────────────────────────────────────────

class PlanificacionException implements Exception {
  final String message;
  const PlanificacionException(this.message);

  @override
  String toString() => message;
}
