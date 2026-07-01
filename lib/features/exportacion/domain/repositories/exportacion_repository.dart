import '../../../../core/models/paginated_response.dart';
import '../entities/exportacion_enums.dart';
import '../entities/export_result.dart';
import '../entities/registro_exportacion_entity.dart';

abstract class ExportacionRepository {
  Future<ExportResult> exportar({
    required TipoExportacion     modulo,
    required FormatoExportacion  formato,
    required Map<String, String> filtros,
  });

  Future<PaginatedResponse<RegistroExportacionEntity>> getLog({
    int              page     = 1,
    int              pageSize = 20,
    TipoExportacion? tipo,
  });
}
