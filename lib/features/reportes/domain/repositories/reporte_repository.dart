import '../entities/reporte_generado_entity.dart';

abstract class ReporteRepository {
  Future<ReporteGeneradoEntity> solicitarReporte({
    required ReporteTipo tipo,
    Map<String, dynamic> filtros = const {},
  });

  Future<ReporteGeneradoEntity> obtenerEstado(int id);
}
