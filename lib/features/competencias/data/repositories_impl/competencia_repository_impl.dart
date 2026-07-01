import '../../domain/repositories/competencia_repository.dart';
import '../datasources/competencia_remote_datasource.dart';
import '../models/competencia_model.dart';
import '../../../../core/models/paginated_response.dart';

class CompetenciaRepositoryImpl implements CompetenciaRepository {
  final CompetenciaRemoteDatasource _datasource;

  const CompetenciaRepositoryImpl({CompetenciaRemoteDatasource? datasource})
      : _datasource = datasource ?? const CompetenciaRemoteDatasource();

  @override
  Future<PaginatedResponse<CompetenciaItem>> list({
    String? search,
    String? tipo,
    int?    asignatura,
    int     page     = 1,
    int     pageSize = 20,
  }) =>
      _datasource.listCompetencias(
        search:     search,
        tipo:       tipo,
        asignatura: asignatura,
        page:       page,
        pageSize:   pageSize,
      );

  @override
  Future<CompetenciaItem> get(int id) => _datasource.getCompetencia(id);

  @override
  Future<CompetenciaItem> createPrincipal(Map<String, dynamic> payload) =>
      _datasource.createCompetenciaPrincipal(payload);

  @override
  Future<CompetenciaItem> createTransversal(Map<String, dynamic> payload) =>
      _datasource.createCompetenciaTransversal(payload);

  @override
  Future<CompetenciaItem> update(int id, Map<String, dynamic> payload) =>
      _datasource.updateCompetencia(id, payload);

  @override
  Future<void> delete(int id) => _datasource.deleteCompetencia(id);
}
