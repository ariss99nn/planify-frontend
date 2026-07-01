// lib/features/aulas/domain/usecases/equipamiento/listar_equipamientos_usecase.dart

import '../../entities/equipamiento_entity.dart';
import '../../entities/paged_result.dart';
import '../../repositories/equipamiento_repository.dart';

class ListarEquipamientosUseCase {
  final EquipamientoRepository repository;
  const ListarEquipamientosUseCase(this.repository);

  Future<PagedResult<EquipamientoResumenEntity>> call({
    String? search,
    String? estado,
    int page = 1,
  }) =>
      repository.getEquipamientos(search: search, estado: estado, page: page);
}