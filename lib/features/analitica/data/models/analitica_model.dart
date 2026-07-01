import '../../domain/entities/analitica_entities.dart';

class SnapshotProgramaModel {
  final int id;
  final int programaId;
  final String programaNombre;
  final int fichasActivas;
  final int fichasLectiva;
  final int fichasProductiva;
  final int estudiantesActivos;
  final int desercionesMes;
  final int graduadosMes;
  final double avanceCurricularPct;
  final int horasPlanificadas;
  final int horasEjecutadas;
  final double avanceHorasPct;

  const SnapshotProgramaModel({
    required this.id,
    required this.programaId,
    required this.programaNombre,
    required this.fichasActivas,
    required this.fichasLectiva,
    required this.fichasProductiva,
    required this.estudiantesActivos,
    required this.desercionesMes,
    required this.graduadosMes,
    required this.avanceCurricularPct,
    required this.horasPlanificadas,
    required this.horasEjecutadas,
    required this.avanceHorasPct,
  });

  factory SnapshotProgramaModel.fromJson(Map<String, dynamic> json) {
    return SnapshotProgramaModel(
      id:                   json['id']               as int,
      programaId:           json['programa']         as int,
      programaNombre:       json['programa_nombre']  as String,
      fichasActivas:        json['fichas_activas']   as int,
      fichasLectiva:        json['fichas_lectiva']   as int,
      fichasProductiva:     json['fichas_productiva'] as int,
      estudiantesActivos:   json['estudiantes_activos'] as int,
      desercionesMes:       json['deserciones_mes']  as int,
      graduadosMes:         json['graduados_mes']    as int,
      avanceCurricularPct: (json['avance_curricular_pct'] as num).toDouble(),
      horasPlanificadas:    json['horas_planificadas'] as int,
      horasEjecutadas:      json['horas_ejecutadas'] as int,
      avanceHorasPct:      (json['avance_horas_pct'] as num).toDouble(),
    );
  }

  SnapshotProgramaEntity toEntity() => SnapshotProgramaEntity(
        id:                  id,
        programaId:          programaId,
        programaNombre:      programaNombre,
        fichasActivas:       fichasActivas,
        fichasLectiva:       fichasLectiva,
        fichasProductiva:    fichasProductiva,
        estudiantesActivos:  estudiantesActivos,
        desercionesMes:      desercionesMes,
        graduadosMes:        graduadosMes,
        avanceCurricularPct: avanceCurricularPct,
        horasPlanificadas:   horasPlanificadas,
        horasEjecutadas:     horasEjecutadas,
        avanceHorasPct:      avanceHorasPct,
      );
}

class AlertaCriticaModel {
  final int id;
  final String descripcion;
  final DateTime fechaCreacion;

  const AlertaCriticaModel({
    required this.id,
    required this.descripcion,
    required this.fechaCreacion,
  });

  factory AlertaCriticaModel.fromJson(Map<String, dynamic> json) {
    return AlertaCriticaModel(
      id:            json['id']             as int,
      descripcion:   json['descripcion']    as String,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
    );
  }

  AlertaCriticaEntity toEntity() => AlertaCriticaEntity(
        id:            id,
        descripcion:   descripcion,
        fechaCreacion: fechaCreacion,
      );
}

class DashboardModel {
  final DateTime fechaSnapshot;
  final int fichasActivas;
  final int fichasLectiva;
  final int fichasProductiva;
  final int estudiantesActivos;
  final int desercionesMes;
  final int graduadosMes;
  final int reasignacionesMes;
  final int docentesActivos;
  final int docentesSobrecargados;
  final int aulasActivas;
  final int aulasMantenimiento;
  final int aulasInactivas;
  final int planesAprobados;
  final int planesPendientes;
  final int alertasPendientes;
  final int conflictosMes;
  final List<SnapshotProgramaModel> breakdownProgramas;
  final List<AlertaCriticaModel> alertasCriticas;

  const DashboardModel({
    required this.fechaSnapshot,
    required this.fichasActivas,
    required this.fichasLectiva,
    required this.fichasProductiva,
    required this.estudiantesActivos,
    required this.desercionesMes,
    required this.graduadosMes,
    required this.reasignacionesMes,
    required this.docentesActivos,
    required this.docentesSobrecargados,
    required this.aulasActivas,
    required this.aulasMantenimiento,
    required this.aulasInactivas,
    required this.planesAprobados,
    required this.planesPendientes,
    required this.alertasPendientes,
    required this.conflictosMes,
    required this.breakdownProgramas,
    required this.alertasCriticas,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final fichas      = json['fichas']      as Map<String, dynamic>;
    final estudiantes = json['estudiantes'] as Map<String, dynamic>;
    final docentes    = json['docentes']    as Map<String, dynamic>;
    final aulas       = json['aulas']       as Map<String, dynamic>;
    final planes      = json['planes']      as Map<String, dynamic>;
    final alertas     = json['alertas']     as Map<String, dynamic>;

    return DashboardModel(
      fechaSnapshot:         DateTime.parse(json['fecha_snapshot'] as String),
      fichasActivas:         fichas['activas']        as int,
      fichasLectiva:         fichas['lectiva']        as int,
      fichasProductiva:      fichas['productiva']     as int,
      estudiantesActivos:    estudiantes['activos']            as int,
      desercionesMes:        estudiantes['deserciones_mes']    as int,
      graduadosMes:          estudiantes['graduados_mes']      as int,
      reasignacionesMes:     estudiantes['reasignaciones_mes'] as int,
      docentesActivos:       docentes['activos']      as int,
      docentesSobrecargados: docentes['sobrecargados'] as int,
      aulasActivas:          aulas['activas']          as int,
      aulasMantenimiento:    aulas['mantenimiento']    as int,
      aulasInactivas:        aulas['inactivas']        as int,
      planesAprobados:       planes['aprobados']       as int,
      planesPendientes:      planes['pendientes']      as int,
      alertasPendientes:     alertas['pendientes']     as int,
      conflictosMes:         alertas['conflictos_mes'] as int,
      breakdownProgramas: (json['breakdown_programas'] as List<dynamic>)
          .map((e) => SnapshotProgramaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      alertasCriticas: (json['alertas_criticas'] as List<dynamic>)
          .map((e) => AlertaCriticaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  DashboardEntity toEntity() => DashboardEntity(
        fechaSnapshot:         fechaSnapshot,
        fichasActivas:         fichasActivas,
        fichasLectiva:         fichasLectiva,
        fichasProductiva:      fichasProductiva,
        estudiantesActivos:    estudiantesActivos,
        desercionesMes:        desercionesMes,
        graduadosMes:          graduadosMes,
        reasignacionesMes:     reasignacionesMes,
        docentesActivos:       docentesActivos,
        docentesSobrecargados: docentesSobrecargados,
        aulasActivas:          aulasActivas,
        aulasMantenimiento:    aulasMantenimiento,
        aulasInactivas:        aulasInactivas,
        planesAprobados:       planesAprobados,
        planesPendientes:      planesPendientes,
        alertasPendientes:     alertasPendientes,
        conflictosMes:         conflictosMes,
        breakdownProgramas:    breakdownProgramas.map((e) => e.toEntity()).toList(),
        alertasCriticas:       alertasCriticas.map((e) => e.toEntity()).toList(),
      );
}

class AnaliticaSnapshotModel {
  final int id;
  final DateTime fecha;
  final int fichasActivas;
  final int fichasLectiva;
  final int fichasProductiva;
  final int estudiantesActivos;
  final int desercionesMes;
  final int graduadosMes;
  final int reasignacionesMes;
  final int docentesActivos;
  final int docentesSobrecargados;
  final int aulasActivas;
  final int aulasMantenimiento;
  final int aulasInactivas;
  final int planesAprobados;
  final int planesPendientes;
  final int alertasPendientes;
  final int conflictosHorarioMes;
  final List<SnapshotProgramaModel> programas;
  final DateTime createdAt;

  const AnaliticaSnapshotModel({
    required this.id,
    required this.fecha,
    required this.fichasActivas,
    required this.fichasLectiva,
    required this.fichasProductiva,
    required this.estudiantesActivos,
    required this.desercionesMes,
    required this.graduadosMes,
    required this.reasignacionesMes,
    required this.docentesActivos,
    required this.docentesSobrecargados,
    required this.aulasActivas,
    required this.aulasMantenimiento,
    required this.aulasInactivas,
    required this.planesAprobados,
    required this.planesPendientes,
    required this.alertasPendientes,
    required this.conflictosHorarioMes,
    required this.programas,
    required this.createdAt,
  });

  factory AnaliticaSnapshotModel.fromJson(Map<String, dynamic> json) {
    return AnaliticaSnapshotModel(
      id:                    json['id']    as int,
      fecha:                 DateTime.parse(json['fecha']      as String),
      fichasActivas:         json['fichas_activas']    as int,
      fichasLectiva:         json['fichas_lectiva']    as int,
      fichasProductiva:      json['fichas_productiva'] as int,
      estudiantesActivos:    json['estudiantes_activos']    as int,
      desercionesMes:        json['deserciones_mes']        as int,
      graduadosMes:          json['graduados_mes']          as int,
      reasignacionesMes:     json['reasignaciones_mes']     as int,
      docentesActivos:       json['docentes_activos']       as int,
      docentesSobrecargados: json['docentes_sobrecargados'] as int,
      aulasActivas:          json['aulas_activas']       as int,
      aulasMantenimiento:    json['aulas_mantenimiento'] as int,
      aulasInactivas:        json['aulas_inactivas']     as int,
      planesAprobados:       json['planes_aprobados']    as int,
      planesPendientes:      json['planes_pendientes']   as int,
      alertasPendientes:     json['alertas_pendientes']      as int,
      conflictosHorarioMes:  json['conflictos_horario_mes']  as int,
      programas: (json['programas'] as List<dynamic>)
          .map((e) => SnapshotProgramaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  AnaliticaSnapshotEntity toEntity() => AnaliticaSnapshotEntity(
        id:                    id,
        fecha:                 fecha,
        fichasActivas:         fichasActivas,
        fichasLectiva:         fichasLectiva,
        fichasProductiva:      fichasProductiva,
        estudiantesActivos:    estudiantesActivos,
        desercionesMes:        desercionesMes,
        graduadosMes:          graduadosMes,
        reasignacionesMes:     reasignacionesMes,
        docentesActivos:       docentesActivos,
        docentesSobrecargados: docentesSobrecargados,
        aulasActivas:          aulasActivas,
        aulasMantenimiento:    aulasMantenimiento,
        aulasInactivas:        aulasInactivas,
        planesAprobados:       planesAprobados,
        planesPendientes:      planesPendientes,
        alertasPendientes:     alertasPendientes,
        conflictosHorarioMes:  conflictosHorarioMes,
        programas:             programas.map((e) => e.toEntity()).toList(),
        createdAt:             createdAt,
      );
}
