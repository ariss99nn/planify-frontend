// lib/features/ficha/data/repositories_impl/ficha_estudiante_repository_impl.dart

import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/ficha_entity.dart';
import '../../domain/repositories/ficha_estudiante_repository.dart';
import '../../data/models/ficha_request_model.dart';
import '../datasources/ficha_remote_datasource.dart';

class FichaEstudianteRepositoryImpl implements FichaEstudianteRepository {
  final FichaRemoteDatasource _datasource;

  FichaEstudianteRepositoryImpl({FichaRemoteDatasource? datasource})
      : _datasource = datasource ?? FichaRemoteDatasource();

  @override
  Future<PaginatedResponse<FichaEstudianteEntity>> getEstudiantes(
    int fichaId, {
    bool? activo,
    bool? esCadena,
    String? motivoRetiro,
    int page     = 1,
    int pageSize = 20,
  }) async {
    final r = await _datasource.getEstudiantes(
      fichaId,
      activo:       activo,
      esCadena:     esCadena,
      motivoRetiro: motivoRetiro,
      page:         page,
      pageSize:     pageSize,
    );
    return PaginatedResponse<FichaEstudianteEntity>(
      count:    r.count,
      next:     r.next,
      previous: r.previous,
      results:  r.results.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<FichaEstudianteEntity> addEstudiante(
    int fichaId,
    AddEstudianteRequest request,
  ) async {
    final model = await _datasource.addEstudiante(
      fichaId,
      estudianteId: request.estudianteId,
      esCadena:     request.esCadena,
    );
    return model.toEntity();
  }

  @override
  Future<FichaEstudianteEntity> updateEstudiante(
    int fichaId,
    int relacionId,
    UpdateEstudianteRequest request,
  ) async {
    final model = await _datasource.updateEstudiante(
      fichaId,
      relacionId,
      request.toJson(),
    );
    return model.toEntity();
  }
}
