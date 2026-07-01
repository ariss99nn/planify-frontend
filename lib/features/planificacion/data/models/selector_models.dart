// lib/features/planificacion/data/models/selector_models.dart

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

abstract class Seleccionable {
  int get id;
  String get tituloPrincipal;
  String? get subtitulo;
}

// ─── FichaSelector ────────────────────────────────────────────────────────────

class FichaSelector implements Seleccionable {
  @override
  final int    id;
  final String codigoFicha;
  final String programaNombre;
  final String jornadaDisplay;
  final String etapaDisplay;

  const FichaSelector({
    required this.id,
    required this.codigoFicha,
    required this.programaNombre,
    required this.jornadaDisplay,
    required this.etapaDisplay,
  });

  factory FichaSelector.fromJson(Map<String, dynamic> j) => FichaSelector(
        id:             j['id'] as int,
        codigoFicha:    j['codigo_ficha'] as String? ?? '',
        programaNombre: j['programa_nombre'] as String? ?? '',
        jornadaDisplay: j['jornada_display'] as String? ?? '',
        etapaDisplay:   j['etapa_display'] as String? ?? '',
      );

  @override
  String get tituloPrincipal => 'Ficha $codigoFicha';

  @override
  String get subtitulo => '$programaNombre · $jornadaDisplay · $etapaDisplay';
}

// ─── CompetenciaSelector ──────────────────────────────────────────────────────

class CompetenciaSelector implements Seleccionable {
  @override
  final int     id;
  final String  codigo;
  final String  nombre;
  final String  tipo;
  final String  tipoDisplay;
  final bool    esInduccion;
  final int?    asignaturaId;
  final String? asignaturaNombre;
  final int     totalResultados;

  const CompetenciaSelector({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.tipo,
    required this.tipoDisplay,
    required this.esInduccion,
    this.asignaturaId,
    this.asignaturaNombre,
    required this.totalResultados,
  });

  factory CompetenciaSelector.fromJson(Map<String, dynamic> j) =>
      CompetenciaSelector(
        id:               j['id'] as int,
        codigo:           j['codigo'] as String? ?? '',
        nombre:           j['nombre'] as String? ?? '',
        tipo:             j['tipo'] as String? ?? '',
        tipoDisplay:      j['tipo_display'] as String? ?? '',
        esInduccion:      j['es_induccion'] as bool? ?? false,
        asignaturaId:     j['asignatura'] as int?,
        asignaturaNombre: j['asignatura_nombre'] as String?,
        totalResultados:  j['total_resultados'] as int? ?? 0,
      );

  bool get esTransversal => asignaturaId == null;

  @override
  String get tituloPrincipal => '$codigo — $nombre';

  @override
  String? get subtitulo => esTransversal
      ? 'Transversal · $totalResultados RAP'
      : '${asignaturaNombre ?? "Sin asignatura"} · $totalResultados RAP';
}

// ─── DocenteSelector ──────────────────────────────────────────────────────────

class DocenteSelector implements Seleccionable {
  @override
  final int     id;
  final String  nombre;
  final String  email;
  final String? especialidad;
  final double  horasMaxSemanales;
  final double  horasAsignadasSemana;
  final bool    estaSobrecargado;
  final bool    estado;

  const DocenteSelector({
    required this.id,
    required this.nombre,
    required this.email,
    this.especialidad,
    required this.horasMaxSemanales,
    required this.horasAsignadasSemana,
    required this.estaSobrecargado,
    required this.estado,
  });

  factory DocenteSelector.fromJson(Map<String, dynamic> j) => DocenteSelector(
        id:                   j['id'] as int,
        nombre:               j['nombre'] as String? ?? '',
        email:                j['email'] as String? ?? '',
        especialidad:         j['especialidad'] as String?,
        horasMaxSemanales:    _toDouble(j['horas_max_semanales']),
        horasAsignadasSemana: _toDouble(j['horas_asignadas_semana']),
        estaSobrecargado:     j['esta_sobrecargado'] as bool? ?? false,
        estado:               j['estado'] as bool? ?? true,
      );

  @override
  String get tituloPrincipal => nombre;

  @override
  String? get subtitulo {
    final carga =
        '${horasAsignadasSemana.toStringAsFixed(0)}h/${horasMaxSemanales.toStringAsFixed(0)}h semanales';
    if (estaSobrecargado) return '$carga · Sobrecargado';
    if (especialidad != null && especialidad!.isNotEmpty) {
      return '$especialidad · $carga';
    }
    return carga;
  }
}
