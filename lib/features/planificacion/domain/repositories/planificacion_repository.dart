// lib/features/planificacion/domain/repositories/planificacion_repository.dart

import '../../../../core/models/paginated_response.dart';
import '../entities/plan_trimestral_entity.dart';

abstract class PlanificacionRepository {
  // ── Planes ─────────────────────────────────────────────────────────────────
  Future<PaginatedResponse<PlanTrimestral>> getPlanes({
    PlanTrimestralFiltros? filtros,
  });

  Future<PlanTrimestralDetalle> getPlanDetalle(int id);

  Future<PlanTrimestralDetalle> crearPlan({
    required int      fichaId,
    required int      trimestre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  });

  Future<PlanTrimestralDetalle> actualizarPlan(
    int id, {
    DateTime? fechaInicio,
    DateTime? fechaFin,
  });

  Future<PlanTrimestralDetalle> cambiarEstado(
    int id, {
    required EstadoPlan nuevoEstado,
    String?             motivoRechazo,
  });

  Future<ResultadoGenerarHorario> generarHorario(int planId);

  // ── Items ──────────────────────────────────────────────────────────────────
  Future<PaginatedResponse<ItemPlan>> getItems({ItemPlanFiltros? filtros});

  Future<ItemPlan> crearItem({
    required int planId,
    required int competenciaId,
    int?         docenteId,
    required int horasAsignadas,
    required int orden,
  });

  Future<ItemPlan> actualizarItem(
    int id, {
    int?  docenteId,
    int?  horasAsignadas,
    int?  orden,
    bool? completado,
  });

  // ── Bloques de competencia ─────────────────────────────────────────────────
  Future<List<BloqueCompetencia>> getBloques({int? planId, int? itemId});

  Future<BloqueCompetencia> crearBloque({
    required int    bloqueId,
    required int    itemPlanId,
    required double horasEjecutadas,
    String          observaciones = '',
  });
}
