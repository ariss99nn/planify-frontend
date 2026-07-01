import '../entities/reporte_generado_entity.dart';
import '../repositories/reporte_repository.dart';

class SolicitarReporteUseCase {
  final ReporteRepository _repo;
  const SolicitarReporteUseCase(this._repo);

  Future<ReporteGeneradoEntity> call({
    required ReporteTipo tipo,
    Map<String, dynamic> filtros = const {},
  }) =>
      _repo.solicitarReporte(tipo: tipo, filtros: filtros);
}

class ObtenerEstadoReporteUseCase {
  final ReporteRepository _repo;
  const ObtenerEstadoReporteUseCase(this._repo);

  Future<ReporteGeneradoEntity> call(int id) => _repo.obtenerEstado(id);
}
