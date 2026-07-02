// lib/features/ficha/data/models/ficha_model.dart

import '../../domain/entities/ficha_entity.dart';

// ── FichaModel ────────────────────────────────────────────────────────────────

class FichaModel {
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
  final List<HistorialEtapaModel> historialEtapasReciente;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FichaModel({
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

  factory FichaModel.fromJson(Map<String, dynamic> json) => FichaModel(
        id:                         json['id'] as int,
        codigoFicha:                json['codigo_ficha'] as String,
        version:                    json['version'] as int,
        programaNombre:             json['programa_nombre'] as String,
        programaNivel:              json['programa_nivel'] as String,
        programaTipoFormacion:      json['programa_tipo_formacion'] as String?,
        versionNumero:              json['version_numero'] as int,
        jornada:                    json['jornada'] as String,
        jornadaDisplay:             json['jornada_display'] as String,
        etapa:                      json['etapa'] as String,
        etapaDisplay:               json['etapa_display'] as String,
        trimestre:                  json['trimestre'] as int,
        trimestresRestantes:        json['trimestres_restantes'] as int?,
        trimestresTotalesModalidad: json['trimestres_totales_modalidad'] as int?,
        trimestresAhorradosCadena:  json['trimestres_ahorrados_cadena'] as int? ?? 0,
        horasSemanalesObjetivo:     json['horas_semanales_objetivo'] as int,
        estado:                     json['estado'] as String,
        cadenaFormacion:            json['cadena_formacion'] as bool,
        numeroEstudiantesEstimado:  json['numero_estudiantes_estimado'] as int,
        numeroEstudiantesReal:      json['numero_estudiantes_real'] as int,
        cupoDisponible:             json['cupo_disponible'] as int? ?? 0,
        jefeGrupo:                  json['jefe_grupo'] as int?,
        jefeGrupoNombre:            json['jefe_grupo_nombre'] as String?,
        jefeGrupoEmail:             json['jefe_grupo_email'] as String?,
        jefeGrupoEspecialidad:      json['jefe_grupo_especialidad'] as String?,
        fechaInicio:                DateTime.parse(json['fecha_inicio'] as String),
        fechaFinalizacion:          json['fecha_finalizacion'] != null
            ? DateTime.parse(json['fecha_finalizacion'] as String)
            : null,
        distribucionSemanalSugerida: (json['distribucion_semanal_sugerida'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        calendarioTrimestres:       (json['calendario_trimestres'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        historialEtapasReciente:    (json['historial_etapas_reciente'] as List? ?? [])
            .map((e) => HistorialEtapaModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt:                  DateTime.parse(json['created_at'] as String),
        updatedAt:                  DateTime.parse(json['updated_at'] as String),
      );

  FichaEntity toEntity() => FichaEntity(
        id:                         id,
        codigoFicha:                codigoFicha,
        version:                    version,
        programaNombre:             programaNombre,
        programaNivel:              programaNivel,
        programaTipoFormacion:      programaTipoFormacion,
        versionNumero:              versionNumero,
        jornada:                    jornada,
        jornadaDisplay:             jornadaDisplay,
        etapa:                      etapa,
        etapaDisplay:               etapaDisplay,
        trimestre:                  trimestre,
        trimestresRestantes:        trimestresRestantes,
        trimestresTotalesModalidad: trimestresTotalesModalidad,
        trimestresAhorradosCadena:  trimestresAhorradosCadena,
        horasSemanalesObjetivo:     horasSemanalesObjetivo,
        estado:                     estado,
        cadenaFormacion:            cadenaFormacion,
        numeroEstudiantesEstimado:  numeroEstudiantesEstimado,
        numeroEstudiantesReal:      numeroEstudiantesReal,
        cupoDisponible:             cupoDisponible,
        jefeGrupo:                  jefeGrupo,
        jefeGrupoNombre:            jefeGrupoNombre,
        jefeGrupoEmail:             jefeGrupoEmail,
        jefeGrupoEspecialidad:      jefeGrupoEspecialidad,
        fechaInicio:                fechaInicio,
        fechaFinalizacion:          fechaFinalizacion,
        distribucionSemanalSugerida: distribucionSemanalSugerida,
        calendarioTrimestres:       calendarioTrimestres,
        historialEtapasReciente:    historialEtapasReciente.map((h) => h.toEntity()).toList(),
        createdAt:                  createdAt,
        updatedAt:                  updatedAt,
      );
}

// ── FichaListModel ─────────────────────────────────────────────────────────────

class FichaListModel {
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

  const FichaListModel({
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

  factory FichaListModel.fromJson(Map<String, dynamic> json) => FichaListModel(
        id:                        json['id'] as int,
        codigoFicha:               json['codigo_ficha'] as String,
        programaNombre:            json['programa_nombre'] as String,
        programaNivel:             json['programa_nivel'] as String?,
        programaTipoFormacion:     json['programa_tipo_formacion'] as String?,
        versionNumero:             json['version_numero'] as int,
        jornada:                   json['jornada'] as String,
        jornadaDisplay:            json['jornada_display'] as String,
        etapa:                     json['etapa'] as String,
        etapaDisplay:              json['etapa_display'] as String,
        trimestre:                 json['trimestre'] as int,
        estado:                    json['estado'] as String,
        cadenaFormacion:           json['cadena_formacion'] as bool,
        numeroEstudiantesEstimado: json['numero_estudiantes_estimado'] as int,
        numeroEstudiantesReal:     json['numero_estudiantes_real'] as int,
        jefeGrupoNombre:           json['jefe_grupo_nombre'] as String?,
        fechaInicio:               DateTime.parse(json['fecha_inicio'] as String),
        fechaFinalizacion:         json['fecha_finalizacion'] != null
            ? DateTime.parse(json['fecha_finalizacion'] as String)
            : null,
      );

  FichaListEntity toEntity() => FichaListEntity(
        id:                        id,
        codigoFicha:               codigoFicha,
        programaNombre:            programaNombre,
        programaNivel:             programaNivel,
        programaTipoFormacion:     programaTipoFormacion,
        versionNumero:             versionNumero,
        jornada:                   jornada,
        jornadaDisplay:            jornadaDisplay,
        etapa:                     etapa,
        etapaDisplay:              etapaDisplay,
        trimestre:                 trimestre,
        estado:                    estado,
        cadenaFormacion:           cadenaFormacion,
        numeroEstudiantesEstimado: numeroEstudiantesEstimado,
        numeroEstudiantesReal:     numeroEstudiantesReal,
        jefeGrupoNombre:           jefeGrupoNombre,
        fechaInicio:               fechaInicio,
        fechaFinalizacion:         fechaFinalizacion,
      );
}

// ── HistorialEtapaModel ────────────────────────────────────────────────────────

class HistorialEtapaModel {
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

  const HistorialEtapaModel({
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

  factory HistorialEtapaModel.fromJson(Map<String, dynamic> json) =>
      HistorialEtapaModel(
        id:                   json['id'] as int,
        ficha:                json['ficha'] as int,
        fichaCodigo:          json['ficha_codigo'] as String,
        etapaAnterior:        json['etapa_anterior'] as String,
        etapaAnteriorDisplay: json['etapa_anterior_display'] as String,
        etapaNueva:           json['etapa_nueva'] as String,
        etapaNuevaDisplay:    json['etapa_nueva_display'] as String,
        trimestre:            json['trimestre'] as int,
        fecha:                DateTime.parse(json['fecha'] as String),
        cambiadoPor:          json['cambiado_por'] as int?,
        cambiadoPorNombre:    json['cambiado_por_nombre'] as String?,
      );

  HistorialEtapaEntity toEntity() => HistorialEtapaEntity(
        id:                   id,
        ficha:                ficha,
        fichaCodigo:          fichaCodigo,
        etapaAnterior:        etapaAnterior,
        etapaAnteriorDisplay: etapaAnteriorDisplay,
        etapaNueva:           etapaNueva,
        etapaNuevaDisplay:    etapaNuevaDisplay,
        trimestre:            trimestre,
        fecha:                fecha,
        cambiadoPor:          cambiadoPor,
        cambiadoPorNombre:    cambiadoPorNombre,
      );
}

// ── FichaEstudianteModel ───────────────────────────────────────────────────────

class FichaEstudianteModel {
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

  const FichaEstudianteModel({
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

  factory FichaEstudianteModel.fromJson(Map<String, dynamic> json) =>
      FichaEstudianteModel(
        id:                           json['id'] as int,
        ficha:                        json['ficha'] as int,
        fichaCodigo:                  json['ficha_codigo'] as String,
        programaNombre:               json['programa_nombre'] as String,
        estudiante:                   json['estudiante'] as int,
        estudianteNombre:             json['estudiante_nombre'] as String,
        estudianteEmail:              json['estudiante_email'] as String,
        activo:                       json['activo'] as bool,
        esCadena:                     json['es_cadena'] as bool,
        fechaIngreso:                 DateTime.parse(json['fecha_ingreso'] as String),
        fechaRetiro:                  json['fecha_retiro'] != null
            ? DateTime.parse(json['fecha_retiro'] as String)
            : null,
        motivoRetiro:                 json['motivo_retiro'] as String?,
        motivoRetiroDisplay:          json['motivo_retiro_display'] as String?,
        horasRestantesParaProductiva: json['horas_restantes_para_productiva'] as int?,
      );

  FichaEstudianteEntity toEntity() => FichaEstudianteEntity(
        id:                           id,
        ficha:                        ficha,
        fichaCodigo:                  fichaCodigo,
        programaNombre:               programaNombre,
        estudiante:                   estudiante,
        estudianteNombre:             estudianteNombre,
        estudianteEmail:              estudianteEmail,
        activo:                       activo,
        esCadena:                     esCadena,
        fechaIngreso:                 fechaIngreso,
        fechaRetiro:                  fechaRetiro,
        motivoRetiro:                 motivoRetiro,
        motivoRetiroDisplay:          motivoRetiroDisplay,
        horasRestantesParaProductiva: horasRestantesParaProductiva,
      );
}

// ── ReasignacionModel ──────────────────────────────────────────────────────────

class ReasignacionModel {
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

  const ReasignacionModel({
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

  factory ReasignacionModel.fromJson(Map<String, dynamic> json) => ReasignacionModel(
        id:                 json['id'] as int,
        estudiante:         json['estudiante'] as int,
        estudianteNombre:   json['estudiante_nombre'] as String,
        fichaOrigen:        json['ficha_origen'] as int,
        fichaOrigenCodigo:  json['ficha_origen_codigo'] as String,
        fichaDestino:       json['ficha_destino'] as int,
        fichaDestinoCodigo: json['ficha_destino_codigo'] as String,
        motivo:             json['motivo'] as String,
        realizadoPor:       json['realizado_por'] as int?,
        realizadoPorNombre: json['realizado_por_nombre'] as String?,
        fecha:              DateTime.parse(json['fecha'] as String),
      );

  ReasignacionEntity toEntity() => ReasignacionEntity(
        id:                 id,
        estudiante:         estudiante,
        estudianteNombre:   estudianteNombre,
        fichaOrigen:        fichaOrigen,
        fichaOrigenCodigo:  fichaOrigenCodigo,
        fichaDestino:       fichaDestino,
        fichaDestinoCodigo: fichaDestinoCodigo,
        motivo:             motivo,
        realizadoPor:       realizadoPor,
        realizadoPorNombre: realizadoPorNombre,
        fecha:              fecha,
      );
}
