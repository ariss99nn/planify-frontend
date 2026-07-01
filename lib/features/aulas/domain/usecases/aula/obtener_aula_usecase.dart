// lib/features/aulas/domain/usecases/aula/obtener_aula_usecase.dart

import '../../entities/aula_entity.dart';
import '../../repositories/aula_repository.dart';

class ObtenerAulaUseCase {
  final AulaRepository repository;
  const ObtenerAulaUseCase(this.repository);

  Future<AulaEntity> call(int id) => repository.getAula(id);
}