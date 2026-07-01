// lib/features/planificacion/domain/usecases/item_usecases.dart

import '../../../../core/models/paginated_response.dart';
import '../entities/plan_trimestral_entity.dart';
import '../repositories/planificacion_repository.dart';

class CargarItemsUseCase {
  final PlanificacionRepository _repo;
  const CargarItemsUseCase(this._repo);

  Future<PaginatedResponse<ItemPlan>> call({ItemPlanFiltros? filtros}) =>
      _repo.getItems(filtros: filtros);
}

class CrearItemUseCase {
  final PlanificacionRepository _repo;
  const CrearItemUseCase(this._repo);

  Future<ItemPlan> call({
    required int planId,
    required int competenciaId,
    int?         docenteId,
    required int horasAsignadas,
    required int orden,
  }) {
    if (horasAsignadas <= 0) {
      throw const PlanificacionException(
          'Las horas asignadas deben ser mayores a 0.');
    }
    return _repo.crearItem(
      planId:         planId,
      competenciaId:  competenciaId,
      docenteId:      docenteId,
      horasAsignadas: horasAsignadas,
      orden:          orden,
    );
  }
}

class ActualizarItemUseCase {
  final PlanificacionRepository _repo;
  const ActualizarItemUseCase(this._repo);

  Future<ItemPlan> call(
    int itemId, {
    int?  docenteId,
    int?  horasAsignadas,
    int?  orden,
    bool? completado,
  }) {
    if (horasAsignadas != null && horasAsignadas <= 0) {
      throw const PlanificacionException(
          'Las horas asignadas deben ser mayores a 0.');
    }
    return _repo.actualizarItem(
      itemId,
      docenteId:      docenteId,
      horasAsignadas: horasAsignadas,
      orden:          orden,
      completado:     completado,
    );
  }
}
