// lib/features/ficha/domain/usecases/ficha/obtener_ficha_usecase.dart

import '../../entities/ficha_entity.dart';
import '../../repositories/ficha_repository.dart';

class ObtenerFichaUseCase {
  final FichaRepository repository;
  const ObtenerFichaUseCase(this.repository);

  Future<FichaEntity> call(int id) => repository.getFicha(id);
}
