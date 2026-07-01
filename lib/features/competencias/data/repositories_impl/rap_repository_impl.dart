import '../../domain/repositories/rap_repository.dart';
import '../datasources/competencia_remote_datasource.dart';
import '../models/rap_model.dart';
import '../../../../core/models/paginated_response.dart';

class RapRepositoryImpl implements RapRepository {
  final CompetenciaRemoteDatasource _datasource;

  const RapRepositoryImpl({CompetenciaRemoteDatasource? datasource})
      : _datasource = datasource ?? const CompetenciaRemoteDatasource();

  @override
  Future<PaginatedResponse<RapItem>> list({
    String? search,
    int?    competencia,
    int     page     = 1,
    int     pageSize = 20,
  }) =>
      _datasource.listRaps(
        search:      search,
        competencia: competencia,
        page:        page,
        pageSize:    pageSize,
      );

  @override
  Future<RapItem> get(int id) => _datasource.getRap(id);

  @override
  Future<RapItem> create(Map<String, dynamic> payload) =>
      _datasource.createRap(payload);

  @override
  Future<RapItem> update(int id, Map<String, dynamic> payload) =>
      _datasource.updateRap(id, payload);

  @override
  Future<void> delete(int id) => _datasource.deleteRap(id);
}
