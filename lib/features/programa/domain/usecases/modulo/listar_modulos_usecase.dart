// lib/features/programa/domain/usecases/modulo/listar_modulos_usecase.dart
import '../../../../../core/models/paginated_response.dart';
import '../../entities/modulo_entity.dart';
import '../../repositories/modulo_repository.dart';

class ListarModulosUseCase {
  final ModuloRepository repository;
  const ListarModulosUseCase(this.repository);

  Future<PaginatedResponse<ModuloResumenEntity>> call({
    int? versionId,
    int? page,
    int? pageSize,
    String? search,
    ModuloEstado? estado,
  }) =>
      repository.list(
        versionId: versionId,
        page: page,
        pageSize: pageSize,
        search: search,
        estado: estado,
      );
}
