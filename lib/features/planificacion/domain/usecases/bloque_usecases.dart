// lib/features/planificacion/domain/usecases/bloque_usecases.dart

import '../entities/plan_trimestral_entity.dart';
import '../repositories/planificacion_repository.dart';

class CargarBloquesUseCase {
  final PlanificacionRepository _repo;
  const CargarBloquesUseCase(this._repo);

  Future<List<BloqueCompetencia>> call({int? planId, int? itemId}) =>
      _repo.getBloques(planId: planId, itemId: itemId);
}

class CrearBloqueUseCase {
  final PlanificacionRepository _repo;
  const CrearBloqueUseCase(this._repo);

  Future<BloqueCompetencia> call({
    required int    bloqueId,
    required int    itemPlanId,
    required double horasEjecutadas,
    String          observaciones = '',
  }) {
    if (horasEjecutadas <= 0) {
      throw const PlanificacionException(
          'Las horas ejecutadas deben ser mayores a 0.');
    }
    return _repo.crearBloque(
      bloqueId:        bloqueId,
      itemPlanId:      itemPlanId,
      horasEjecutadas: horasEjecutadas,
      observaciones:   observaciones,
    );
  }
}
