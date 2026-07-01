// lib/features/ficha/domain/repositories/reasignacion_repository.dart

import '../../../../core/models/paginated_response.dart';
import '../entities/ficha_entity.dart';
import '../../data/models/ficha_request_model.dart';

abstract class ReasignacionRepository {
  Future<PaginatedResponse<ReasignacionEntity>> getReasignaciones({
    int? estudianteId,
    int? fichaOrigenId,
    int? fichaDestinoId,
    int page,
    int pageSize,
  });

  Future<ReasignacionEntity> createReasignacion(ReasignacionCreateRequest request);
}
