// lib/features/ficha/domain/usecases/ficha/crear_ficha_usecase.dart

import '../../entities/ficha_entity.dart';
import '../../repositories/ficha_repository.dart';
import '../../../data/models/ficha_request_model.dart';

class CrearFichaUseCase {
  final FichaRepository repository;
  const CrearFichaUseCase(this.repository);

  Future<FichaEntity> call(FichaCreateRequest request) =>
      repository.createFicha(request);
}
