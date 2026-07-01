// lib/features/ficha/domain/usecases/ficha/get_historial_usecase.dart

import '../../../../../core/models/paginated_response.dart';
import '../../entities/ficha_entity.dart';
import '../../repositories/ficha_repository.dart';

class GetHistorialUseCase {
  final FichaRepository repository;
  const GetHistorialUseCase(this.repository);

  Future<PaginatedResponse<HistorialEtapaEntity>> call({
    int? fichaId,
    String? etapaNueva,
    String? etapaAnterior,
    int page     = 1,
    int pageSize = 20,
  }) =>
      repository.getHistorial(
        fichaId:       fichaId,
        etapaNueva:    etapaNueva,
        etapaAnterior: etapaAnterior,
        page:          page,
        pageSize:      pageSize,
      );
}
