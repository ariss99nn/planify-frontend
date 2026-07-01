// lib/features/aulas/domain/usecases/bloque/obtener_bloque_usecase.dart

import '../../entities/bloque_entity.dart';
import '../../repositories/bloque_repository.dart';

class ObtenerBloqueUseCase {
  final BloqueRepository repository;
  const ObtenerBloqueUseCase(this.repository);

  Future<BloqueDetalleEntity> call(int id) => repository.getBloque(id);
}