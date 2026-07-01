enum TipoExportacion {
  fichas  ('FICHAS',   'Fichas'),
  docentes('DOCENTES', 'Docentes'),
  horarios('HORARIOS', 'Horarios');

  const TipoExportacion(this.value, this.label);
  final String value;
  final String label;

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
