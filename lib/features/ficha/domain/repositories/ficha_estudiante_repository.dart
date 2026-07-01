// lib/features/ficha/domain/repositories/ficha_estudiante_repository.dart

import '../../../../core/models/paginated_response.dart';
import '../entities/ficha_entity.dart';
import '../../data/models/ficha_request_model.dart';

abstract class FichaEstudianteRepository {
  Future<PaginatedResponse<FichaEstudianteEntity>> getEstudiantes(
    int fichaId, {
    bool? activo,
    bool? esCadena,
    String? motivoRetiro,
    int page,
    int pageSize,
  });

  Future<FichaEstudianteEntity> addEstudiante(
    int fichaId,
    AddEstudianteRequest request,
  );

  Future<FichaEstudianteEntity> updateEstudiante(
    int fichaId,
    int relacionId,
    UpdateEstudianteRequest request,
  );
}
