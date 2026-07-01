// lib/features/programa/domain/repositories/modulo_repository.dart
import '../../../../core/models/paginated_response.dart';
import '../entities/modulo_entity.dart';

abstract class ModuloRepository {
  Future<PaginatedResponse<ModuloResumenEntity>> list({
    int? versionId,
    int? page,
    int? pageSize,
    String? search,
    ModuloEstado? estado,
  });

  Future<ModuloEntity> detail(int id);

  Future<ModuloEntity> create({
    required int versionId,
    required String nombre,
    required int orden,
    required int horasLectivas,
    required int horasPracticas,
    String descripcion,
    ModuloEstado estado,
  });

  Future<ModuloEntity> update({
    required int id,
    String? nombre,
    int? orden,
    int? horasLectivas,
    int? horasPracticas,
    String? descripcion,
    ModuloEstado? estado,
  });
}
