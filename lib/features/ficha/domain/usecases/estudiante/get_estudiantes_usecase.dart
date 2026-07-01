// lib/features/ficha/domain/usecases/estudiante/get_estudiantes_usecase.dart

import '../../../../../core/models/paginated_response.dart';
import '../../entities/ficha_entity.dart';
import '../../repositories/ficha_estudiante_repository.dart';

class GetEstudiantesUseCase {
  final FichaEstudianteRepository repository;
  const GetEstudiantesUseCase(this.repository);

  Future<PaginatedResponse<FichaEstudianteEntity>> call(
    int fichaId, {
    bool? activo,
    bool? esCadena,
    String? motivoRetiro,
    int page     = 1,
    int pageSize = 50,
  }) =>
      repository.getEstudiantes(
        fichaId,
        activo:       activo,
        esCadena:     esCadena,
        motivoRetiro: motivoRetiro,
        page:         page,
        pageSize:     pageSize,
      );
}
