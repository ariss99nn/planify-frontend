enum ReporteTipo {
  fichas,
  docentes,
  horarios,
  competencias,
  aulas,
  planes,
  analitica,
  novedades,
}

extension ReporteTipoX on ReporteTipo {
  String get value {
    switch (this) {
      case ReporteTipo.fichas:
        return 'FICHAS';
      case ReporteTipo.docentes:
        return 'DOCENTES';
      case ReporteTipo.horarios:
        return 'HORARIOS';
      case ReporteTipo.competencias:
        return 'COMPETENCIAS';
      case ReporteTipo.aulas:
        return 'AULAS';
      case ReporteTipo.planes:
        return 'PLANES';
      case ReporteTipo.analitica:
        return 'ANALITICA';
      case ReporteTipo.novedades:
        return 'NOVEDADES';
    }
  }

  String get label {
    switch (this) {
      case ReporteTipo.fichas:
        return 'Fichas';
      case ReporteTipo.docentes:
        return 'Docentes';
      case ReporteTipo.horarios:
        return 'Horarios';
      case ReporteTipo.competencias:
        return 'Competencias';
      case ReporteTipo.aulas:
        return 'Aulas';
      case ReporteTipo.planes:
        return 'Planes';
      case ReporteTipo.analitica:
        return 'Analítica';
      case ReporteTipo.novedades:
        return 'Novedades';
    }
  }

  /// Debe reflejar exactamente los tipos registrados en
  /// `ReportesConfig.ready()` (back/reportes/apps.py) contra
  /// `ReporteFactory`. FICHAS, DOCENTES, AULAS, HORARIOS, COMPETENCIAS
  /// y PLANES ya tienen generador registrado; ANALITICA y NOVEDADES
  /// todavía no, por lo que siguen marcados "Próximamente".
  bool get implementadoEnBackend {
    return this == ReporteTipo.fichas ||
        this == ReporteTipo.docentes ||
        this == ReporteTipo.aulas ||
        this == ReporteTipo.horarios ||
        this == ReporteTipo.competencias ||
        this == ReporteTipo.planes;
  }

  static ReporteTipo fromValue(String raw) {
    return ReporteTipo.values.firstWhere(
      (t) => t.value == raw,
      orElse: () => ReporteTipo.fichas,
    );
  }

  /// Debe reflejar `TIPOS_PERMITIDOS_NO_GESTION` en
  /// reportes/serializers/reporte_generado_serializer.py.
  static List<ReporteTipo> permitidosParaRol(String rol) {
    const docenteRol = 'DOCENTE';
    if (rol == docenteRol) {
      return [ReporteTipo.fichas, ReporteTipo.horarios];
    }
    return ReporteTipo.values;
  }
}

enum EstadoReporte { pendiente, procesando, listo, error }

extension EstadoReporteX on EstadoReporte {
  String get value {
    switch (this) {
      case EstadoReporte.pendiente:
        return 'PENDIENTE';
      case EstadoReporte.procesando:
        return 'PROCESANDO';
      case EstadoReporte.listo:
        return 'LISTO';
      case EstadoReporte.error:
        return 'ERROR';
    }
  }

  bool get esFinal =>
      this == EstadoReporte.listo || this == EstadoReporte.error;

  static EstadoReporte fromValue(String raw) {
    return EstadoReporte.values.firstWhere(
      (e) => e.value == raw,
      orElse: () => EstadoReporte.pendiente,
    );
  }
}

class ReporteGeneradoEntity {
  final int id;
  final ReporteTipo tipo;
  final String tipoDisplay;
  final EstadoReporte estado;
  final String estadoDisplay;
  final int usuario;
  final String usuarioNombre;
  final Map<String, dynamic> filtros;
  final String? tareaId;
  final String? archivoPdfUrl;
  final String? archivoExcelUrl;
  final String errorMensaje;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReporteGeneradoEntity({
    required this.id,
    required this.tipo,
    required this.tipoDisplay,
    required this.estado,
    required this.estadoDisplay,
    required this.usuario,
    required this.usuarioNombre,
    required this.filtros,
    this.tareaId,
    this.archivoPdfUrl,
    this.archivoExcelUrl,
    required this.errorMensaje,
    required this.createdAt,
    required this.updatedAt,
  });
}
