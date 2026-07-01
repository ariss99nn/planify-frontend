// lib/features/aulas/domain/usecases/equipamiento/obtener_equipamiento_usecase.dart

import '../../entities/equipamiento_entity.dart';
import '../../repositories/equipamiento_repository.dart';

class ObtenerEquipamientoUseCase {
  final EquipamientoRepository repository;
  const ObtenerEquipamientoUseCase(this.repository);

  Future<EquipamientoDetalleEntity> call(int id) => repository.getEquipamiento(id);
}