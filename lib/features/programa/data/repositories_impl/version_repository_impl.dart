// lib/features/programa/data/repositories_impl/version_repository_impl.dart
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/version_programa_entity.dart';
import '../../domain/repositories/version_repository.dart';
import '../datasources/version_remote_datasource.dart';

class VersionRepositoryImpl implements VersionRepository {
  final VersionRemoteDatasource _datasource;

  VersionRepositoryImpl({VersionRemoteDatasource? datasource})
      : _datasource = datasource ?? VersionRemoteDatasource();

  @override
  Future<PaginatedResponse<VersionResumenEntity>> list({
    int? programaId,
    int? page,
    int? pageSize,
    String? search,
    bool? vigente,
  }) async {
    final response = await _datasource.list(
      programaId: programaId,
      page: page,
      pageSize: pageSize,
      search: search,
      vigente: vigente,
    );
    return PaginatedResponse<VersionResumenEntity>(
      count: response.count,
      next: response.next,
      previous: response.previous,
      results: response.results.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<VersionEntity> detail(int id) async {
    final model = await _datasource.detail(id);
    return model.toEntity();
  }

  @override
  Future<VersionEntity> create({
    required int programaId,
    required int numero,
    String descripcion = '',
    bool vigente = false,
    required DateTime fechaInicio,
    DateTime? fechaFin,
  }) async {
    final model = await _datasource.create(
      programaId: programaId,
      numero: numero,
      descripcion: descripcion,
      vigente: vigente,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
    );
    return model.toEntity();
  }

  @override
  Future<VersionEntity> update({
    required int id,
    String? descripcion,
    bool? vigente,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    final model = await _datasource.update(
      id: id,
      descripcion: descripcion,
      vigente: vigente,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
    );
    return model.toEntity();
  }
}
