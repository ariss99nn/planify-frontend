// lib/features/ficha/data/repositories_impl/reasignacion_repository_impl.dart

import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/ficha_entity.dart';
import '../../domain/repositories/reasignacion_repository.dart';
import '../../data/models/ficha_request_model.dart';
import '../datasources/ficha_remote_datasource.dart';

class ReasignacionRepositoryImpl implements ReasignacionRepository {
  final FichaRemoteDatasource _datasource;

  ReasignacionRepositoryImpl({FichaRemoteDatasource? datasource})
      : _datasource = datasource ?? FichaRemoteDatasource();

  @override
  Future<PaginatedResponse<ReasignacionEntity>> getReasignaciones({
    int? estudianteId,
    int? fichaOrigenId,
    int? fichaDestinoId,
    int page     = 1,
    int pageSize = 20,
  }) async {
    final r = await _datasource.getReasignaciones(
      estudianteId:   estudianteId,
      fichaOrigenId:  fichaOrigenId,
      fichaDestinoId: fichaDestinoId,
      page:           page,
      pageSize:       pageSize,
    );
    return PaginatedResponse<ReasignacionEntity>(
      count:    r.count,
      next:     r.next,
      previous: r.previous,
      results:  r.results.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<ReasignacionEntity> createReasignacion(
    ReasignacionCreateRequest request,
  ) async {
    final model = await _datasource.createReasignacion(request.toJson());
    return model.toEntity();
  }
}
