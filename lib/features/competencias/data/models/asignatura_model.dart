class AsignaturaItem {
  final int    id;
  final int?   moduloId;
  final String nombre;
  final String descripcion;
  final int    orden;
  final String moduloNombre;
  final String tipo;
  final String tipoDisplay;
  final String estado;
  final String estadoDisplay;
  final int    horasLectivas;
  final int    horasPracticas;
  final int    totalHoras;
  final int    totalCompetencias;

  final List<Map<String, dynamic>> competencias;
  final List<Map<String, dynamic>> docentesAsignados;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AsignaturaItem({
    required this.id,
    this.moduloId,
    required this.nombre,
    this.descripcion        = '',
    required this.orden,
    required this.moduloNombre,
    required this.tipo,
    required this.tipoDisplay,
    required this.estado,
    required this.estadoDisplay,
    required this.horasLectivas,
    required this.horasPracticas,
    required this.totalHoras,
    required this.totalCompetencias,
    this.competencias       = const [],
    this.docentesAsignados  = const [],
    this.createdAt,
    this.updatedAt,
  });

  bool get isActiva => estado == 'ACTIVA';

  factory AsignaturaItem.fromListJson(Map<String, dynamic> j) {
    return AsignaturaItem(
      id:                 j['id']                as int,
      nombre:             j['nombre']             as String,
      orden:              j['orden']              as int,
      moduloNombre:       (j['modulo_nombre']     as String?) ?? '',
      tipo:               j['tipo']               as String,
      tipoDisplay:        (j['tipo_display']      as String?) ?? j['tipo'] as String,
      estado:             j['estado']             as String,
      estadoDisplay:      (j['estado_display']    as String?) ?? j['estado'] as String,
      horasLectivas:      j['horas_lectivas']     as int,
      horasPracticas:     j['horas_practicas']    as int,
      totalHoras:         j['total_horas']        as int,
      totalCompetencias:  j['total_competencias'] as int? ?? 0,
    );
  }

  factory AsignaturaItem.fromDetailJson(Map<String, dynamic> j) {
    return AsignaturaItem(
      id:            j['id']             as int,
      moduloId:      j['modulo']         as int?,
      nombre:        j['nombre']         as String,
      descripcion:   (j['descripcion']   as String?) ?? '',
      orden:         j['orden']          as int,
      moduloNombre:  (j['modulo_nombre'] as String?) ?? '',
      tipo:          j['tipo']           as String,
      tipoDisplay:   (j['tipo_display']  as String?) ?? j['tipo'] as String,
      estado:        j['estado']         as String,
      estadoDisplay: (j['estado_display'] as String?) ?? j['estado'] as String,
      horasLectivas:    j['horas_lectivas']  as int,
      horasPracticas:   j['horas_practicas'] as int,
      totalHoras:       j['total_horas']     as int,
      totalCompetencias: 0,
      competencias: (j['competencias'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      docentesAsignados: (j['docentes_asignados'] as List?)
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
