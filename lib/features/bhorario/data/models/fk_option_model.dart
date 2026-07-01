// lib/features/bhorario/data/models/fk_option_model.dart

/// Representación mínima de una entidad FK para uso en pickers del form.
/// Cada factory normaliza la respuesta de su endpoint respectivo.
class FkOption {
  final int     id;
  final String  display;   // Texto principal
  final String? subtitle;  // Info secundaria (tipo, email, programa…)

  const FkOption({
    required this.id,
    required this.display,
    this.subtitle,
  });

  @override
  String toString() => display;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is FkOption && other.id == id);

  @override
  int get hashCode => id.hashCode;

  // ── Factories por módulo ────────────────────────────────────────────────────

  /// GET /aulas/  →  {id, codigo_aula, tipo_aula / tipo_aula_display}
  factory FkOption.fromAulaJson(Map<String, dynamic> json) {
    final id     = json['id'] as int;
    final codigo = json['codigo_aula'] as String? ?? 'Aula $id';
    final tipo   = json['tipo_aula_display'] as String? ??
                   json['tipo_aula'] as String?;
    return FkOption(id: id, display: codigo, subtitle: tipo);
  }

  /// GET /docentes/
  /// Soporta:  { user: {nombre, email} }
  ///        o  { nombre_completo, email }
  factory FkOption.fromDocenteJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    String display;
    String? subtitle;

    if (json['user'] is Map) {
      final u = json['user'] as Map<String, dynamic>;
      display  = u['nombre']     as String? ??
                 u['full_name']  as String? ??
                 '${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'.trim();
      subtitle = u['email'] as String?;
    } else {
      display  = json['nombre_completo'] as String? ??
                 json['nombre']          as String? ??
                 'Docente $id';
      subtitle = json['email'] as String?;
    }

    if (display.trim().isEmpty) display = 'Docente $id';
    return FkOption(id: id, display: display, subtitle: subtitle);
  }

  /// GET /fichas/  →  {id, codigo_ficha, version: {programa: {nombre}}}
  factory FkOption.fromFichaJson(Map<String, dynamic> json) {
    final id     = json['id'] as int;
    final codigo = json['codigo_ficha'] as String? ?? 'Ficha $id';
    String? programa;

    if (json['version'] is Map) {
      final ver = json['version'] as Map<String, dynamic>;
      if (ver['programa'] is Map) {
        programa = (ver['programa'] as Map<String, dynamic>)['nombre'] as String?;
      }
    }
    programa ??= json['programa_nombre'] as String?;

    return FkOption(id: id, display: codigo, subtitle: programa);
  }

  /// GET /competencia/competencias/  →  {id, nombre, tipo / tipo_display}
  factory FkOption.fromCompetenciaJson(Map<String, dynamic> json) {
    final id     = json['id'] as int;
    final nombre = json['nombre'] as String? ?? 'Competencia $id';
    final tipo   = json['tipo_display'] as String? ??
                   json['tipo']         as String?;
    return FkOption(id: id, display: nombre, subtitle: tipo);
  }
}