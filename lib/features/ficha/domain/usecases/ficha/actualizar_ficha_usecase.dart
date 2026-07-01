// lib/features/ficha/domain/usecases/ficha/actualizar_ficha_usecase.dart

import '../../entities/ficha_entity.dart';
import '../../repositories/ficha_repository.dart';
import '../../../data/models/ficha_request_model.dart';

class ActualizarFichaUseCase {
  final FichaRepository repository;
  const ActualizarFichaUseCase(this.repository);

  Future<FichaEntity> call(int id, FichaUpdateRequest request) =>
      repository.updateFicha(id, request);
}
