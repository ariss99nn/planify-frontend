class CompetenciaItem {
  final int     id;
  final int?    asignaturaId;
  final String? asignaturaNombre;
  final String  codigo;
  final String  nombre;
  final String  descripcion;
  final String  tipo;
  final String  tipoDisplay;
  final bool    esInduccion;
  final bool    inductionActiva;
  final int?    horasTrimestre;
  final int     totalResultados;

  final List<Map<String, dynamic>> resultados;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompetenciaItem({
    required this.id,
    this.asignaturaId,
    this.asignaturaNombre,
    required this.codigo,
    required this.nombre,
    this.descripcion     = '',
    required this.tipo,
    required this.tipoDisplay,
    this.esInduccion     = false,
    this.inductionActiva = true,
    this.horasTrimestre,
    this.totalResultados = 0,
    this.resultados      = const [],
    this.createdAt,
    this.updatedAt,
  });

  bool get isPrincipal   => tipo == 'PRINCIPAL';
  bool get isTransversal => tipo == 'TRANSVERSAL';

  factory CompetenciaItem.fromListJson(Map<String, dynamic> j) {
    return CompetenciaItem(
      id:               j['id']               as int,
      asignaturaId:     j['asignatura']        as int?,
      asignaturaNombre: j['asignatura_nombre'] as String?,
      codigo:           j['codigo']            as String,
      nombre:           j['nombre']            as String,
      tipo:             (j['tipo']             as String?) ?? 'PRINCIPAL',
      tipoDisplay:      (j['tipo_display']     as String?) ?? '',
      esInduccion:      (j['es_induccion']     as bool?)   ?? false,
      inductionActiva:  (j['induccion_activa'] as bool?)   ?? true,
      totalResultados:  (j['total_resultados'] as int?)    ?? 0,
    );
  }

  factory CompetenciaItem.fromDetailJson(Map<String, dynamic> j) {
    return CompetenciaItem(
      id:               j['id']                          as int,
      asignaturaId:     j['asignatura']                  as int?,
      asignaturaNombre: j['asignatura_nombre']            as String?,
      codigo:           j['codigo']                      as String,
      nombre:           j['nombre']                      as String,
      descripcion:      (j['descripcion']                as String?) ?? '',
      tipo:             (j['tipo']                       as String?) ?? 'PRINCIPAL',
      tipoDisplay:      (j['tipo_display']               as String?) ?? '',
      esInduccion:      (j['es_induccion']               as bool?)   ?? false,
      inductionActiva:  (j['induccion_activa']           as bool?)   ?? true,
      horasTrimestre:   j['horas_trimestre_transversal'] as int?,
      resultados: (j['resultados'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'] as String)
          : null,
      updatedAt: j['updated_at'] != null
          ? DateTime.tryParse(j['updated_at'] as String)
          : null,
    );
  }
}
