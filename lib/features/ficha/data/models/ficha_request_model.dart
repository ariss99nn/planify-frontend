// lib/features/ficha/data/models/ficha_request_model.dart

String _fmtDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

// ── Ficha ──────────────────────────────────────────────────────────────────────

class FichaCreateRequest {
  final String codigoFicha;
  final int versionId;
  final String jornada;
  final int numeroEstudiantesEstimado;
  final String etapa;
  final int horasSemanalesObjetivo;
  final int trimestre;
  final String estado;
  final bool cadenaFormacion;
  final int? jefeGrupoId;
  final DateTime fechaInicio;
  final DateTime? fechaFinalizacion;

  const FichaCreateRequest({
    required this.codigoFicha,
    required this.versionId,
    required this.jornada,
    required this.numeroEstudiantesEstimado,
    required this.etapa,
    required this.horasSemanalesObjetivo,
    required this.trimestre,
    required this.estado,
    required this.cadenaFormacion,
    this.jefeGrupoId,
    required this.fechaInicio,
    this.fechaFinalizacion,
  });

  Map<String, dynamic> toJson() => {
        'codigo_ficha':                codigoFicha,
        'version':                     versionId,
        'jornada':                     jornada,
        'numero_estudiantes_estimado': numeroEstudiantesEstimado,
        'etapa':                       etapa,
        'horas_semanales_objetivo':    horasSemanalesObjetivo,
        'trimestre':                   trimestre,
        'estado':                      estado,
        'cadena_formacion':            cadenaFormacion,
        if (jefeGrupoId != null) 'jefe_grupo': jefeGrupoId,
        'fecha_inicio':                _fmtDate(fechaInicio),
        if (fechaFinalizacion != null)
          'fecha_finalizacion': _fmtDate(fechaFinalizacion!),
      };
}

class FichaUpdateRequest {
  final String? jornada;
  final int? numeroEstudiantesEstimado;
  final int? horasSemanalesObjetivo;
  final int? trimestre;
  final String? estado;
  final bool? cadenaFormacion;
  final int? jefeGrupoId;
  final bool clearJefeGrupo;
  final DateTime? fechaInicio;
  final DateTime? fechaFinalizacion;

  const FichaUpdateRequest({
    this.jornada,
    this.numeroEstudiantesEstimado,
    this.horasSemanalesObjetivo,
    this.trimestre,
    this.estado,
    this.cadenaFormacion,
    this.jefeGrupoId,
    this.clearJefeGrupo = false,
    this.fechaInicio,
    this.fechaFinalizacion,
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (jornada != null)                   m['jornada']                     = jornada;
    if (numeroEstudiantesEstimado != null) m['numero_estudiantes_estimado'] = numeroEstudiantesEstimado;
    if (horasSemanalesObjetivo != null)    m['horas_semanales_objetivo']    = horasSemanalesObjetivo;
    if (trimestre != null)                 m['trimestre']                   = trimestre;
    if (estado != null)                    m['estado']                      = estado;
    if (cadenaFormacion != null)           m['cadena_formacion']            = cadenaFormacion;
    if (clearJefeGrupo) {
      m['jefe_grupo'] = null;
    } else if (jefeGrupoId != null) {
      m['jefe_grupo'] = jefeGrupoId;
    }
    if (fechaInicio != null)       m['fecha_inicio']       = _fmtDate(fechaInicio!);
    if (fechaFinalizacion != null) m['fecha_finalizacion'] = _fmtDate(fechaFinalizacion!);
    return m;
  }
}

class EtapaUpdateRequest {
  final String etapa;
  final int trimestre;

  const EtapaUpdateRequest({required this.etapa, required this.trimestre});

  Map<String, dynamic> toJson() => {'etapa': etapa, 'trimestre': trimestre};
}

// ── Estudiante ─────────────────────────────────────────────────────────────────

class AddEstudianteRequest {
  final int estudianteId;
  final bool esCadena;

  const AddEstudianteRequest({
    required this.estudianteId,
    required this.esCadena,
  });

  Map<String, dynamic> toJson(int fichaId) => {
        'ficha':      fichaId,
        'estudiante': estudianteId,
        'es_cadena':  esCadena,
      };
}

class UpdateEstudianteRequest {
  final bool? activo;
  final DateTime? fechaRetiro;
  final String? motivoRetiro;

  const UpdateEstudianteRequest({
    this.activo,
    this.fechaRetiro,
    this.motivoRetiro,
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (activo != null)       m['activo']        = activo;
    if (fechaRetiro != null)  m['fecha_retiro']  = _fmtDate(fechaRetiro!);
    if (motivoRetiro != null) m['motivo_retiro'] = motivoRetiro;
    return m;
  }
}

// ── Reasignación ───────────────────────────────────────────────────────────────

class ReasignacionCreateRequest {
  final int estudianteId;
  final int fichaOrigenId;
  final int fichaDestinoId;
  final String motivo;

  const ReasignacionCreateRequest({
    required this.estudianteId,
    required this.fichaOrigenId,
    required this.fichaDestinoId,
    required this.motivo,
  });

  Map<String, dynamic> toJson() => {
        'estudiante':    estudianteId,
        'ficha_origen':  fichaOrigenId,
        'ficha_destino': fichaDestinoId,
        'motivo':        motivo,
      };
}
