import '../../data/models/asignatura_model.dart';
import '../../../../core/models/paginated_response.dart';

abstract class AsignaturaRepository {
  Future<PaginatedResponse<AsignaturaItem>> list({
    String? search,
    String? tipo,
    String? estado,
    int?    modulo,
    int     page,
    int     pageSize,
  });

  Future<AsignaturaItem> get(int id);
  Future<AsignaturaItem> create(Map<String, dynamic> payload);
  Future<AsignaturaItem> update(int id, Map<String, dynamic> payload);
  Future<void>           delete(int id);
}
