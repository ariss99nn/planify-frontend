import '../../domain/entities/reporte_generado_entity.dart';

class ReporteGeneradoModel extends ReporteGeneradoEntity {
  const ReporteGeneradoModel({
    required super.id,
    required super.tipo,
    required super.tipoDisplay,
    required super.estado,
    required super.estadoDisplay,
    required super.usuario,
    required super.usuarioNombre,
    required super.filtros,
    super.tareaId,
    super.archivoPdfUrl,
    super.archivoExcelUrl,
    required super.errorMensaje,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReporteGeneradoModel.fromJson(Map<String, dynamic> json) {
    return ReporteGeneradoModel(
      id: json['id'] as int,
      tipo: ReporteTipoX.fromValue(json['tipo'] as String),
      tipoDisplay: json['tipo_display'] as String? ?? '',
      estado: EstadoReporteX.fromValue(json['estado'] as String),
      estadoDisplay: json['estado_display'] as String? ?? '',
      usuario: json['usuario'] as int? ?? 0,
      usuarioNombre: json['usuario_nombre'] as String? ?? '',
      filtros: (json['filtros'] as Map?)?.cast<String, dynamic>() ?? const {},
      tareaId: json['tarea_id'] as String?,
      archivoPdfUrl: json['archivo_pdf'] as String?,
      archivoExcelUrl: json['archivo_excel'] as String?,
      errorMensaje: json['error_mensaje'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
