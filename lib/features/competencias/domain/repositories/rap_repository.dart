import '../../data/models/rap_model.dart';
import '../../../../core/models/paginated_response.dart';

abstract class RapRepository {
  Future<PaginatedResponse<RapItem>> list({
    String? search,
    int?    competencia,
    int     page,
    int     pageSize,
  });

  Future<RapItem> get(int id);
  Future<RapItem> create(Map<String, dynamic> payload);
  Future<RapItem> update(int id, Map<String, dynamic> payload);
  Future<void>    delete(int id);
}
