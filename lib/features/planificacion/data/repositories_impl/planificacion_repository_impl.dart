// lib/features/planificacion/data/repositories_impl/planificacion_repository_impl.dart

import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/plan_trimestral_entity.dart';
import '../../domain/repositories/planificacion_repository.dart';
import '../datasources/planificacion_remote_datasource.dart';
import '../models/plan_trimestral_model.dart';

class PlanificacionRepositoryImpl implements PlanificacionRepository {
  final PlanificacionRemoteDatasource _ds;

  PlanificacionRepositoryImpl({PlanificacionRemoteDatasource? datasource})
      : _ds = datasource ?? PlanificacionRemoteDatasource();

  // ── Planes ─────────────────────────────────────────────────────────────────

  @override
  Future<PaginatedResponse<PlanTrimestral>> getPlanes({
    PlanTrimestralFiltros? filtros,
  }) async {
    final raw = await _ds.getPlanes(filtros: filtros);
    return PaginatedResponse<PlanTrimestral>(
      count:    raw['count']    as int? ?? 0,
      next:     raw['next']     as String?,
      previous: raw['previous'] as String?,
      results:  (raw['results'] as List<dynamic>? ?? [])
          .map((e) =>
              PlanTrimestralModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList(),
    );
  }

  @override
  Future<PlanTrimestralDetalle> getPlanDetalle(int id) async {
    final model = await _ds.getPlanDetalle(id);
    return model.toDetalleEntity();
  }

  @override
  Future<PlanTrimestralDetalle> crearPlan({
    required int      fichaId,
    required int      trimestre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    final model = await _ds.crearPlan(
      fichaId:     fichaId,
      trimestre:   trimestre,
      fechaInicio: fechaInicio,
      fechaFin:    fechaFin,
    );
    return model.toDetalleEntity();
  }

  @override
  Future<PlanTrimestralDetalle> actualizarPlan(
    int id, {
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    final model = await _ds.actualizarPlan(id,
        fechaInicio: fechaInicio, fechaFin: fechaFin);
    return model.toDetalleEntity();
  }

  @override
  Future<PlanTrimestralDetalle> cambiarEstado(
    int id, {
    required EstadoPlan nuevoEstado,
    String?             motivoRechazo,
  }) async {
    final model = await _ds.cambiarEstado(id,
        nuevoEstado: nuevoEstado, motivoRechazo: motivoRechazo);
    return model.toDetalleEntity();
  }

  @override
  Future<ResultadoGenerarHorario> generarHorario(int planId) async {
    final model = await _ds.generarHorario(planId);
    return model.toEntity();
  }

  @override
  Future<ResultadoAutoGeneracion> autoGenerarPlan({
    required int      fichaId,
    required int      trimestre,
    DateTime?         fechaInicio,
    DateTime?         fechaFin,
  }) async {
    final model = await _ds.autoGenerarPlan(
      fichaId:     fichaId,
      trimestre:   trimestre,
      fechaInicio: fechaInicio,
      fechaFin:    fechaFin,
    );
    return model.toEntity();
  }

  // ── Items ──────────────────────────────────────────────────────────────────

  @override
  Future<PaginatedResponse<ItemPlan>> getItems({
    ItemPlanFiltros? filtros,
  }) async {
    final raw = await _ds.getItems(filtros: filtros);
    return PaginatedResponse<ItemPlan>(
      count:    raw['count']    as int? ?? 0,
      next:     raw['next']     as String?,
      previous: raw['previous'] as String?,
      results:  (raw['results'] as List<dynamic>? ?? [])
          .map((e) =>
              ItemPlanModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList(),
    );
  }

  @override
  Future<ItemPlan> crearItem({
    required int planId,
    required int competenciaId,
    int?         docenteId,
    required int horasAsignadas,
    required int orden,
  }) async {
    final model = await _ds.crearItem(
      planId:         planId,
      competenciaId:  competenciaId,
      docenteId:      docenteId,
      horasAsignadas: horasAsignadas,
      orden:          orden,
    );
    return model.toEntity();
  }

  @override
  Future<ItemPlan> actualizarItem(
    int id, {
    int?  docenteId,
    int?  horasAsignadas,
    int?  orden,
    bool? completado,
  }) async {
    final model = await _ds.actualizarItem(
      id,
      docenteId:      docenteId,
      horasAsignadas: horasAsignadas,
      orden:          orden,
      completado:     completado,
    );
    return model.toEntity();
  }

  // ── Bloques de competencia ─────────────────────────────────────────────────

  @override
  Future<List<BloqueCompetencia>> getBloques({
    int? planId,
    int? itemId,
  }) async {
    final models = await _ds.getBloques(planId: planId, itemId: itemId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<BloqueCompetencia> crearBloque({
    required int    bloqueId,
    required int    itemPlanId,
    required double horasEjecutadas,
    String          observaciones = '',
  }) async {
    final model = await _ds.crearBloque(
      bloqueId:        bloqueId,
      itemPlanId:      itemPlanId,
      horasEjecutadas: horasEjecutadas,
      observaciones:   observaciones,
    );
    return model.toEntity();
  }
}
