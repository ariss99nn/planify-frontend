// lib/features/aulas/domain/usecases/aula/listar_aulas_usecase.dart

import '../../entities/aula_entity.dart';
import '../../entities/paged_result.dart';
import '../../repositories/aula_repository.dart';

class ListarAulasUseCase {
  final AulaRepository repository;
  const ListarAulasUseCase(this.repository);

  Future<PagedResult<AulaResumenEntity>> call({
    String? search,
    String? estado,
    String? tipoAula,
    int? bloqueId,
    int page = 1,
  }) =>
      repository.getAulas(
        search:   search,
        estado:   estado,
        tipoAula: tipoAula,
        bloqueId: bloqueId,
        page:     page,
      );
}