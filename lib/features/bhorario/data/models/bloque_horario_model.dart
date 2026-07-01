// lib/features/bhorario/data/models/bloque_horario_model.dart

class BloqueHorarioModel {
  final int id;
  final String diaSemana;
  final String diaSemanaDisplay;
  final String horaInicio;
  final String horaFin;
  final String jornada;
  final String jornadaDisplay;
  final bool esRecurrente;
  final String? fechaEspecifica;
  final int? aulaId;
  final String? aulaCodigo;
  final String? aulaTipo;
  final int? docenteId;
  final String? docenteNombre;
  final String? docenteEmail;
  final int? fichaId;
  final String? fichaCodigo;
  final String? fichaPrograma;
  final int? competenciaId;
  final String? competenciaNombre;
  final int alertasActivas;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BloqueHorarioModel({
    required this.id,
    required this.diaSemana,
    required this.diaSemanaDisplay,
    required this.horaInicio,
    required this.horaFin,
    required this.jornada,
    required this.jornadaDisplay,
    required this.esRecurrente,
    this.fechaEspecifica,
    this.aulaId,
    this.aulaCodigo,
    this.aulaTipo,
    this.docenteId,
    this.docenteNombre,
    this.docenteEmail,
    this.fichaId,
    this.fichaCodigo,
    this.fichaPrograma,
    this.competenciaId,
    this.competenciaNombre,
    this.alertasActivas = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory BloqueHorarioModel.fromJson(Map<String, dynamic> json) {
    return BloqueHorarioModel(
      id:                 json['id'] as int,
      diaSemana:          json['dia_semana'] as String,
      diaSemanaDisplay:   (json['dia_semana_display'] ?? json['dia_semana']) as String,
      horaInicio:         json['hora_inicio'] as String,
      horaFin:            json['hora_fin'] as String,
      jornada:            json['jornada'] as String,
      jornadaDisplay:     (json['jornada_display'] ?? json['jornada']) as String,
      esRecurrente:       json['es_recurrente'] as bool? ?? true,
      fechaEspecifica:    json['fecha_especifica'] as String?,
      aulaId:             json['aula'] as int?,
      aulaCodigo:         json['aula_codigo'] as String?,
      aulaTipo:           json['aula_tipo'] as String?,
      docenteId:          json['docente'] as int?,
      docenteNombre:      json['docente_nombre'] as String?,
      docenteEmail:       json['docente_email'] as String?,
      fichaId:            json['ficha'] as int?,
      fichaCodigo:        json['ficha_codigo'] as String?,
      fichaPrograma:      json['ficha_programa'] as String?,
      competenciaId:      json['competencia'] as int?,
      competenciaNombre:  json['competencia_nombre'] as String?,
      alertasActivas:     json['alertas_activas'] as int? ?? 0,
      createdAt:          json['created_at'] != null
                              ? DateTime.tryParse(json['created_at'] as String)
                              : null,
      updatedAt:          json['updated_at'] != null
                              ? DateTime.tryParse(json['updated_at'] as String)
                              : null,
    );
  }

  Map<String, dynamic> toCreateJson() => {
    'dia_semana':   diaSemana,
    'hora_inicio':  horaInicio,
    'hora_fin':     horaFin,
    'jornada':      jornada,
    'es_recurrente': esRecurrente,
    if (fechaEspecifica != null) 'fecha_especifica': fechaEspecifica,
    if (aulaId != null)         'aula': aulaId,
    if (docenteId != null)      'docente': docenteId,
    if (fichaId != null)        'ficha': fichaId,
    if (competenciaId != null)  'competencia': competenciaId,
  };

  // ── Helpers de display ──────────────────────────────────────────────────────

  /// "06:00:00" → "06:00"
  String _shortTime(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    return '${parts[0].padLeft(2, '0')}:${parts[1]}';
  }

  String get horaInicioDisplay => _shortTime(horaInicio);
  String get horaFinDisplay    => _shortTime(horaFin);
  String get rangoHoras        => '$horaInicioDisplay – $horaFinDisplay';
}

// ── Response wrapper para el endpoint /semanal/ ─────────────────────────────

class DiaSemanalData {
  final String diaDisplay;
  final List<BloqueHorarioModel> bloques;

  const DiaSemanalData({required this.diaDisplay, required this.bloques});

  factory DiaSemanalData.fromJson(Map<String, dynamic> json) => DiaSemanalData(
    diaDisplay: json['dia_display'] as String,
    bloques: (json['bloques'] as List<dynamic>)
        .map((b) => BloqueHorarioModel.fromJson(b as Map<String, dynamic>))
        .toList(),
  );
}

class HorarioSemanalResponse {
  final int totalBloques;
  final Map<String, DiaSemanalData> dias;

  const HorarioSemanalResponse({
    required this.totalBloques,
    required this.dias,
  });

  factory HorarioSemanalResponse.fromJson(Map<String, dynamic> json) {
    final diasRaw = json['dias'] as Map<String, dynamic>? ?? {};
    return HorarioSemanalResponse(
      totalBloques: json['total_bloques'] as int? ?? 0,
      dias: diasRaw.map(
        (k, v) => MapEntry(k, DiaSemanalData.fromJson(v as Map<String, dynamic>)),
      ),
    );
  }
}