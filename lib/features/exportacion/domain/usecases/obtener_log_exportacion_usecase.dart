import '../../../../core/models/paginated_response.dart';
import '../entities/exportacion_enums.dart';
import '../entities/registro_exportacion_entity.dart';
import '../repositories/exportacion_repository.dart';

class ObtenerLogExportacionUseCase {
  final ExportacionRepository _repository;

  const ObtenerLogExportacionUseCase(this._repository);

  Future<PaginatedResponse<RegistroExportacionEntity>> call({
    int              page     = 1,
    int              pageSize = 20,
    TipoExportacion? tipo,
  }) =>
      _repository.getLog(page: page, pageSize: pageSize, tipo: tipo);
}
