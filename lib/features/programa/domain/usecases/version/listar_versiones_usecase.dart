// lib/features/programa/domain/usecases/version/listar_versiones_usecase.dart
import '../../../../../core/models/paginated_response.dart';
import '../../entities/version_programa_entity.dart';
import '../../repositories/version_repository.dart';

class ListarVersionesUseCase {
  final VersionRepository repository;
  const ListarVersionesUseCase(this.repository);

  Future<PaginatedResponse<VersionResumenEntity>> call({
    int? programaId,
    int? page,
    int? pageSize,
    String? search,
    bool? vigente,
  }) =>
      repository.list(
        programaId: programaId,
        page: page,
        pageSize: pageSize,
        search: search,
        vigente: vigente,
      );
}
