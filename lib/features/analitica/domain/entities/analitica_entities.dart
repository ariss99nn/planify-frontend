class SnapshotProgramaEntity {
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

  const SnapshotProgramaEntity({
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
}

class AlertaCriticaEntity {
  final int id;
  final String descripcion;
  final DateTime fechaCreacion;

  const AlertaCriticaEntity({
    required this.id,
    required this.descripcion,
    required this.fechaCreacion,
  });
}

class DashboardEntity {
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
  final List<SnapshotProgramaEntity> breakdownProgramas;
  final List<AlertaCriticaEntity> alertasCriticas;

  const DashboardEntity({
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
}

class AnaliticaSnapshotEntity {
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
  final List<SnapshotProgramaEntity> programas;
  final DateTime createdAt;

  const AnaliticaSnapshotEntity({
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
}
