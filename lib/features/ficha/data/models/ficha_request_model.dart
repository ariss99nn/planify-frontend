// lib/features/ficha/data/models/ficha_request_model.dart

String _fmtDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

// ── Ficha ──────────────────────────────────────────────────────────────────────

/// Nota: 'horas_semanales_objetivo', 'trimestre' y 'fecha_finalizacion' ya
/// NO se envían al crear una ficha — el backend los calcula automáticamente
/// a partir de las horas del programa/versión y su nivel de formación.
class FichaCreateRequest {
  final String codigoFicha;
  final int versionId;
  final String jornada;
  final int numeroEstudiantesEstimado;
  final String etapa;
  final String estado;
  final bool cadenaFormacion;
  final int? jefeGrupoId;
  final DateTime? fechaInicio;

  const FichaCreateRequest({
    required this.codigoFicha,
    required this.versionId,
    required this.jornada,
    required this.numeroEstudiantesEstimado,
    required this.etapa,
    required this.estado,
    required this.cadenaFormacion,
    this.jefeGrupoId,
    this.fechaInicio,
  });

  Map<String, dynamic> toJson() => {
        'codigo_ficha':                codigoFicha,
        'version':                     versionId,
        'jornada':                     jornada,
        'numero_estudiantes_estimado': numeroEstudiantesEstimado,
        'etapa':                       etapa,
        'estado':                      estado,
        'cadena_formacion':            cadenaFormacion,
        if (jefeGrupoId != null) 'jefe_grupo': jefeGrupoId,
        if (fechaInicio != null) 'fecha_inicio': _fmtDate(fechaInicio!),
      };
}

/// Nota: 'horas_semanales_objetivo', 'trimestre', 'cadena_formacion' y
/// 'fecha_finalizacion' ya NO son editables desde aquí. La cadena de
/// formación solo se define al crear la ficha; la fecha fin y las horas se
/// recalculan automáticamente en el backend.
/// 'numero_estudiantes_estimado' (cupo) tampoco se edita: queda fijo desde
/// la creación de la ficha — lo que varía con el tiempo es el número real
/// de estudiantes activos, que se calcula solo.
/// Reemplazar el jefe de grupo por otro distinto exige
/// 'confirmarCambioDocente=true'; no aplica al asignar uno por primera vez
/// ni al quitarlo.
class FichaUpdateRequest {
  final String? jornada;
  final String? estado;
  final int? jefeGrupoId;
  final bool clearJefeGrupo;
  final bool confirmarCambioDocente;
  final DateTime? fechaInicio;

  const FichaUpdateRequest({
    this.jornada,
    this.estado,
    this.jefeGrupoId,
    this.clearJefeGrupo = false,
    this.confirmarCambioDocente = false,
    this.fechaInicio,
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (jornada != null) m['jornada'] = jornada;
    if (estado != null)  m['estado']  = estado;
    if (clearJefeGrupo) {
      m['jefe_grupo'] = null;
    } else if (jefeGrupoId != null) {
      m['jefe_grupo'] = jefeGrupoId;
      m['confirmar_cambio_docente'] = confirmarCambioDocente;
    }
    if (fechaInicio != null) m['fecha_inicio'] = _fmtDate(fechaInicio!);
    return m;
  }
}

/// 'trimestre' ya no se envía: solo avanza mediante el flujo dedicado de
/// avance de trimestre; el cambio de etapa solo transmite la etapa nueva.
class EtapaUpdateRequest {
  final String etapa;

  const EtapaUpdateRequest({required this.etapa});

  Map<String, dynamic> toJson() => {'etapa': etapa};
}

// ── Estudiante ─────────────────────────────────────────────────────────────────

/// 'es_cadena' ya NO se envía: el backend lo deriva automáticamente de
/// 'ficha.cadena_formacion' para mantener la coherencia ficha/estudiante.
class AddEstudianteRequest {
  final int estudianteId;

  const AddEstudianteRequest({required this.estudianteId});

  Map<String, dynamic> toJson(int fichaId) => {
        'ficha':      fichaId,
        'estudiante': estudianteId,
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
