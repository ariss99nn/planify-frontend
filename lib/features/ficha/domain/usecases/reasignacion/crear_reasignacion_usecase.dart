// lib/features/ficha/domain/usecases/reasignacion/crear_reasignacion_usecase.dart

import '../../entities/ficha_entity.dart';
import '../../repositories/reasignacion_repository.dart';
import '../../../data/models/ficha_request_model.dart';

class CrearReasignacionUseCase {
  final ReasignacionRepository repository;
  const CrearReasignacionUseCase(this.repository);

  Future<ReasignacionEntity> call(ReasignacionCreateRequest request) =>
      repository.createReasignacion(request);
}
