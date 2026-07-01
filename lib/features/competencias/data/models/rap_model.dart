class RapItem {
  final int     id;
  final int?    competenciaId;
  final String? competenciaNombre;
  final String? competenciaCodigo;
  final String? competenciaTipo;
  final String  codigo;
  final String  descripcion;
  final String  criteriosEvaluacion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RapItem({
    required this.id,
    this.competenciaId,
    this.competenciaNombre,
    this.competenciaCodigo,
    this.competenciaTipo,
    required this.codigo,
    required this.descripcion,
    this.criteriosEvaluacion = '',
    this.createdAt,
    this.updatedAt,
  });

  factory RapItem.fromListJson(Map<String, dynamic> j) {
    return RapItem(
      id:                j['id']                 as int,
      competenciaNombre: j['competencia_nombre']  as String?,
      codigo:            j['codigo']              as String,
      descripcion:       j['descripcion']         as String,
    );
  }

  factory RapItem.fromDetailJson(Map<String, dynamic> j) {
    final comp = j['competencia'] as Map<String, dynamic>?;
    return RapItem(
      id:                   j['id']                     as int,
      competenciaId:        comp?['id']                 as int?,
      competenciaNombre:    comp?['nombre']             as String?,
      competenciaCodigo:    comp?['codigo']             as String?,
      competenciaTipo:      comp?['tipo']               as String?,
      codigo:               j['codigo']                 as String,
      descripcion:          j['descripcion']            as String,
      criteriosEvaluacion:  (j['criterios_evaluacion'] as String?) ?? '',
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'] as String)
          : null,
      updatedAt: j['updated_at'] != null
          ? DateTime.tryParse(j['updated_at'] as String)
          : null,
    );
  }
}
