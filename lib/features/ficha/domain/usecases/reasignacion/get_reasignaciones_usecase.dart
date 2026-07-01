// lib/features/ficha/domain/usecases/reasignacion/get_reasignaciones_usecase.dart

import '../../../../../core/models/paginated_response.dart';
import '../../entities/ficha_entity.dart';
import '../../repositories/reasignacion_repository.dart';

class GetReasignacionesUseCase {
  final ReasignacionRepository repository;
  const GetReasignacionesUseCase(this.repository);

  Future<PaginatedResponse<ReasignacionEntity>> call({
    int? estudianteId,
    int? fichaOrigenId,
    int? fichaDestinoId,
    int page     = 1,
    int pageSize = 20,
  }) =>
      repository.getReasignaciones(
        estudianteId:   estudianteId,
        fichaOrigenId:  fichaOrigenId,
        fichaDestinoId: fichaDestinoId,
        page:           page,
        pageSize:       pageSize,
      );
}
