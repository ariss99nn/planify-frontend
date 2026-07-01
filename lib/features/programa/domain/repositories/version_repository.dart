// lib/features/programa/domain/repositories/version_repository.dart
import '../../../../core/models/paginated_response.dart';
import '../entities/version_programa_entity.dart';

abstract class VersionRepository {
  Future<PaginatedResponse<VersionResumenEntity>> list({
    int? programaId,
    int? page,
    int? pageSize,
    String? search,
    bool? vigente,
  });

  Future<VersionEntity> detail(int id);

  Future<VersionEntity> create({
    required int programaId,
    required int numero,
    String descripcion,
    bool vigente,
    required DateTime fechaInicio,
    DateTime? fechaFin,
  });

  Future<VersionEntity> update({
    required int id,
    String? descripcion,
    bool? vigente,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  });
}
