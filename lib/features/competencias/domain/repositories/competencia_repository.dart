import '../../data/models/competencia_model.dart';
import '../../../../core/models/paginated_response.dart';

abstract class CompetenciaRepository {
  Future<PaginatedResponse<CompetenciaItem>> list({
    String? search,
    String? tipo,
    int?    asignatura,
    int     page,
    int     pageSize,
  });

  Future<CompetenciaItem> get(int id);
  Future<CompetenciaItem> createPrincipal(Map<String, dynamic> payload);
  Future<CompetenciaItem> createTransversal(Map<String, dynamic> payload);
  Future<CompetenciaItem> update(int id, Map<String, dynamic> payload);
  Future<void>            delete(int id);
}
