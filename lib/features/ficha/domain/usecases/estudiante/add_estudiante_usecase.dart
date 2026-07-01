// lib/features/ficha/domain/usecases/estudiante/add_estudiante_usecase.dart

import '../../entities/ficha_entity.dart';
import '../../repositories/ficha_estudiante_repository.dart';
import '../../../data/models/ficha_request_model.dart';

class AddEstudianteUseCase {
  final FichaEstudianteRepository repository;
  const AddEstudianteUseCase(this.repository);

  Future<FichaEstudianteEntity> call(int fichaId, AddEstudianteRequest request) =>
      repository.addEstudiante(fichaId, request);
}
