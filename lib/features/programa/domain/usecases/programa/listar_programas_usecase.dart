// lib/features/programa/domain/usecases/programa/listar_programas_usecase.dart
import '../../../../../core/models/paginated_response.dart';
import '../../entities/programa_entity.dart';
import '../../repositories/programa_repository.dart';

class ListarProgramasUseCase {
  final ProgramaRepository repository;
  const ListarProgramasUseCase(this.repository);

  Future<PaginatedResponse<ProgramaResumenEntity>> call({
    int? page,
    int? pageSize,
    String? search,
    ProgramaNivel? nivel,
    ProgramaEstado? estado,
  }) =>
      repository.list(
        page: page,
        pageSize: pageSize,
        search: search,
        nivel: nivel,
        estado: estado,
      );
}
