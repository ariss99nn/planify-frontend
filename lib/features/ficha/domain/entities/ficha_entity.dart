// lib/features/ficha/domain/entities/ficha_entity.dart

class FichaEntity {
  final int id;
  final String codigoFicha;
  final int version;
  final String programaNombre;
  final String programaNivel;
  final String? programaTipoFormacion;
  final int versionNumero;
  final String jornada;
  final String jornadaDisplay;
  final String etapa;
  final String etapaDisplay;
  final int trimestre;
  final int? trimestresRestantes;
  final int? trimestresTotalesModalidad;
  final int trimestresAhorradosCadena;
  final int horasSemanalesObjetivo;
  final String estado;
  final bool cadenaFormacion;
  final int numeroEstudiantesEstimado;
  final int numeroEstudiantesReal;
  final int cupoDisponible;
  final int? jefeGrupo;
  final String? jefeGrupoNombre;
  final String? jefeGrupoEmail;
  final String? jefeGrupoEspecialidad;
  final DateTime fechaInicio;
  final DateTime? fechaFinalizacion;
  final List<Map<String, dynamic>> distribucionSemanalSugerida;
  final List<Map<String, dynamic>> calendarioTrimestres;
  final List<HistorialEtapaEntity> historialEtapasReciente;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FichaEntity({
    required this.id,
    required this.codigoFicha,
    required this.version,
    required this.programaNombre,
    required this.programaNivel,
    this.programaTipoFormacion,
    required this.versionNumero,
    required this.jornada,
    required this.jornadaDisplay,
    required this.etapa,
    required this.etapaDisplay,
    required this.trimestre,
    this.trimestresRestantes,
    this.trimestresTotalesModalidad,
    this.trimestresAhorradosCadena = 0,
    required this.horasSemanalesObjetivo,
    required this.estado,
    required this.cadenaFormacion,
    required this.numeroEstudiantesEstimado,
    required this.numeroEstudiantesReal,
    this.cupoDisponible = 0,
    this.jefeGrupo,
    this.jefeGrupoNombre,
    this.jefeGrupoEmail,
    this.jefeGrupoEspecialidad,
    required this.fechaInicio,
    this.fechaFinalizacion,
    this.distribucionSemanalSugerida = const [],
    this.calendarioTrimestres = const [],
    required this.historialEtapasReciente,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get estaActiva    => estado == 'ACTIVA';
  bool get estaInactiva  => estado == 'INACTIVA';
  bool get estaCerrada   => estado == 'CERRADA';
  bool get esLectiva     => etapa == 'LECTIVA';
  bool get esProductiva  => etapa == 'PRODUCTIVA';
}

// ── FichaListEntity ────────────────────────────────────────────────────────────

class FichaListEntity {
  final int id;
  final String codigoFicha;
  final String programaNombre;
  final String? programaNivel;
  final String? programaTipoFormacion;
  final int versionNumero;
  final String jornada;
  final String jornadaDisplay;
  final String etapa;
  final String etapaDisplay;
  final int trimestre;
  final String estado;
  final bool cadenaFormacion;
  final int numeroEstudiantesEstimado;
  final int numeroEstudiantesReal;
  final String? jefeGrupoNombre;
  final DateTime fechaInicio;
  final DateTime? fechaFinalizacion;

  const FichaListEntity({
    required this.id,
    required this.codigoFicha,
    required this.programaNombre,
    this.programaNivel,
    this.programaTipoFormacion,
    required this.versionNumero,
    required this.jornada,
    required this.jornadaDisplay,
    required this.etapa,
    required this.etapaDisplay,
    required this.trimestre,
    required this.estado,
    required this.cadenaFormacion,
    required this.numeroEstudiantesEstimado,
    required this.numeroEstudiantesReal,
    this.jefeGrupoNombre,
    required this.fechaInicio,
    this.fechaFinalizacion,
  });

  bool get estaActiva   => estado == 'ACTIVA';
  bool get esLectiva    => etapa == 'LECTIVA';
  bool get esProductiva => etapa == 'PRODUCTIVA';
}

// ── HistorialEtapaEntity ───────────────────────────────────────────────────────

class HistorialEtapaEntity {
  final int id;
  final int ficha;
  final String fichaCodigo;
  final String etapaAnterior;
  final String etapaAnteriorDisplay;
  final String etapaNueva;
  final String etapaNuevaDisplay;
  final int trimestre;
  final DateTime fecha;
  final int? cambiadoPor;
  final String? cambiadoPorNombre;

  const HistorialEtapaEntity({
    required this.id,
    required this.ficha,
    required this.fichaCodigo,
    required this.etapaAnterior,
    required this.etapaAnteriorDisplay,
    required this.etapaNueva,
    required this.etapaNuevaDisplay,
    required this.trimestre,
    required this.fecha,
    this.cambiadoPor,
    this.cambiadoPorNombre,
  });
}

// ── FichaEstudianteEntity ──────────────────────────────────────────────────────

class FichaEstudianteEntity {
  final int id;
  final int ficha;
  final String fichaCodigo;
  final String programaNombre;
  final int estudiante;
  final String estudianteNombre;
  final String estudianteEmail;
  final bool activo;
  final bool esCadena;
  final DateTime fechaIngreso;
  final DateTime? fechaRetiro;
  final String? motivoRetiro;
  final String? motivoRetiroDisplay;
  final int? horasRestantesParaProductiva;

  const FichaEstudianteEntity({
    required this.id,
    required this.ficha,
    required this.fichaCodigo,
    required this.programaNombre,
    required this.estudiante,
    required this.estudianteNombre,
    required this.estudianteEmail,
    required this.activo,
    required this.esCadena,
    required this.fechaIngreso,
    this.fechaRetiro,
    this.motivoRetiro,
    this.motivoRetiroDisplay,
    this.horasRestantesParaProductiva,
  });
}

// ── ReasignacionEntity ─────────────────────────────────────────────────────────

class ReasignacionEntity {
  final int id;
  final int estudiante;
  final String estudianteNombre;
  final int fichaOrigen;
  final String fichaOrigenCodigo;
  final int fichaDestino;
  final String fichaDestinoCodigo;
  final String motivo;
  final int? realizadoPor;
  final String? realizadoPorNombre;
  final DateTime fecha;

  const ReasignacionEntity({
    required this.id,
    required this.estudiante,
    required this.estudianteNombre,
    required this.fichaOrigen,
    required this.fichaOrigenCodigo,
    required this.fichaDestino,
    required this.fichaDestinoCodigo,
    required this.motivo,
    this.realizadoPor,
    this.realizadoPorNombre,
    required this.fecha,
  });
}
