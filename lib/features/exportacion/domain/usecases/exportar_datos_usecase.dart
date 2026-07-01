import '../entities/exportacion_enums.dart';
import '../entities/export_result.dart';
import '../repositories/exportacion_repository.dart';

class ExportarDatosUseCase {
  final ExportacionRepository _repository;

  const ExportarDatosUseCase(this._repository);

  Future<ExportResult> call({
    required TipoExportacion     modulo,
    required FormatoExportacion  formato,
    Map<String, String> filtros = const {},
  }) =>
      _repository.exportar(modulo: modulo, formato: formato, filtros: filtros);
}
