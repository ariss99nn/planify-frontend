// lib/features/ficha/data/repositories_impl/estudiante_bloqueo_repository_impl.dart

import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/estudiante_bloqueo_entity.dart';
import '../../domain/repositories/estudiante_bloqueo_repository.dart';
import '../datasources/estudiante_bloqueo_remote_datasource.dart';

class EstudianteBloqueoRepositoryImpl implements EstudianteBloqueoRepository {
  final EstudianteBloqueoRemoteDatasource _datasource;

  EstudianteBloqueoRepositoryImpl({EstudianteBloqueoRemoteDatasource? datasource})
      : _datasource = datasource ?? EstudianteBloqueoRemoteDatasource();

  @override
  Future<PaginatedResponse<EstudianteBloqueoEntity>> listar({bool? activo}) async {
    final r = await _datasource.getBloqueos(activo: activo, pageSize: 100);
    return PaginatedResponse<EstudianteBloqueoEntity>(
      count:    r.count,
      next:     r.next,
      previous: r.previous,
      results:  r.results.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<EstudianteBloqueoEntity> desbloquear(int id, {String observacion = ''}) async {
    final model = await _datasource.desbloquear(id, observacion: observacion);
    return model.toEntity();
  }
}
