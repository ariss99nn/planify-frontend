import '../../domain/repositories/asignatura_repository.dart';
import '../datasources/competencia_remote_datasource.dart';
import '../models/asignatura_model.dart';
import '../../../../core/models/paginated_response.dart';

class AsignaturaRepositoryImpl implements AsignaturaRepository {
  final CompetenciaRemoteDatasource _datasource;

  const AsignaturaRepositoryImpl({CompetenciaRemoteDatasource? datasource})
      : _datasource = datasource ?? const CompetenciaRemoteDatasource();

  @override
  Future<PaginatedResponse<AsignaturaItem>> list({
    String? search,
    String? tipo,
    String? estado,
    int?    modulo,
    int     page     = 1,
    int     pageSize = 20,
  }) =>
      _datasource.listAsignaturas(
        search:   search,
        tipo:     tipo,
        estado:   estado,
        modulo:   modulo,
        page:     page,
        pageSize: pageSize,
      );

  @override
  Future<AsignaturaItem> get(int id) => _datasource.getAsignatura(id);

  @override
  Future<AsignaturaItem> create(Map<String, dynamic> payload) =>
      _datasource.createAsignatura(payload);

  @override
  Future<AsignaturaItem> update(int id, Map<String, dynamic> payload) =>
      _datasource.updateAsignatura(id, payload);

  @override
  Future<void> delete(int id) => _datasource.deleteAsignatura(id);
}
