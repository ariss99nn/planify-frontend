// lib/features/ficha/domain/usecases/ficha/listar_fichas_usecase.dart

import '../../../../../core/models/paginated_response.dart';
import '../../entities/ficha_entity.dart';
import '../../repositories/ficha_repository.dart';

class ListarFichasUseCase {
  final FichaRepository repository;
  const ListarFichasUseCase(this.repository);

  Future<PaginatedResponse<FichaListEntity>> call({
    String? search,
    String? etapa,
    String? jornada,
    String? estado,
    bool? cadenaFormacion,
    int? programa,
    int? version,
    int? jefeGrupo,
    int page     = 1,
    int pageSize = 20,
  }) =>
      repository.getFichas(
        search: search, etapa: etapa, jornada: jornada, estado: estado,
        cadenaFormacion: cadenaFormacion, programa: programa,
        version: version, jefeGrupo: jefeGrupo, page: page, pageSize: pageSize,
      );
}
