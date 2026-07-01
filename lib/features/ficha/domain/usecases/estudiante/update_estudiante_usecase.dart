// lib/features/ficha/domain/usecases/estudiante/update_estudiante_usecase.dart

import '../../entities/ficha_entity.dart';
import '../../repositories/ficha_estudiante_repository.dart';
import '../../../data/models/ficha_request_model.dart';

class UpdateEstudianteUseCase {
  final FichaEstudianteRepository repository;
  const UpdateEstudianteUseCase(this.repository);

  Future<FichaEstudianteEntity> call(
    int fichaId,
    int relacionId,
    UpdateEstudianteRequest request,
  ) =>
      repository.updateEstudiante(fichaId, relacionId, request);
}
