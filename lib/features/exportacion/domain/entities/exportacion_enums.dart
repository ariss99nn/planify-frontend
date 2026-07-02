enum TipoExportacion {
  fichas      ('FICHAS',       'Fichas'),
  estudiantes ('ESTUDIANTES',  'Estudiantes'),
  docentes    ('DOCENTES',     'Docentes'),
  horarios    ('HORARIOS',     'Horarios'),
  aulas       ('AULAS',        'Aulas'),
  planes      ('PLANES',       'Planes trimestrales'),
  competencias('COMPETENCIAS', 'Competencias'),
  analitica   ('ANALITICA',    'Analítica'),
  completa    ('COMPLETA',     'Base de datos completa');

  const TipoExportacion(this.value, this.label);
  final String value;
  final String label;

  /// La exportación completa combina todas las tablas en un solo
  /// archivo (una hoja por módulo) y por eso solo admite Excel.
  bool get soloExcel => this == TipoExportacion.completa;

  static TipoExportacion? fromValue(String v) {
    for (final e in TipoExportacion.values) {
      if (e.value == v) return e;
    }
    return null;
  }
}

enum FormatoExportacion {
  excel('EXCEL', 'Excel (.xlsx)', 'xlsx'),
  csv  ('CSV',   'CSV',           'csv');

  const FormatoExportacion(this.value, this.label, this.extension);
  final String value;
  final String label;
  final String extension;

  static FormatoExportacion? fromValue(String v) {
    for (final e in FormatoExportacion.values) {
      if (e.value == v) return e;
    }
    return null;
  }
}
