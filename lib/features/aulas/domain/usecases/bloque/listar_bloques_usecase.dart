// lib/features/aulas/domain/usecases/bloque/listar_bloques_usecase.dart

import '../../entities/bloque_entity.dart';
import '../../entities/paged_result.dart';
import '../../repositories/bloque_repository.dart';

class ListarBloquesUseCase {
  final BloqueRepository repository;
  const ListarBloquesUseCase(this.repository);

  Future<PagedResult<BloqueResumenEntity>> call({
    String? search,
    String? estado,
    int page = 1,
  }) =>
      repository.getBloques(search: search, estado: estado, page: page);
}