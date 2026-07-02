// lib/features/planificacion/domain/usecases/plan_usecases.dart

import '../../../../core/models/paginated_response.dart';
import '../entities/plan_trimestral_entity.dart';
import '../repositories/planificacion_repository.dart';

class CargarPlanesUseCase {
  final PlanificacionRepository _repo;
  const CargarPlanesUseCase(this._repo);

  Future<PaginatedResponse<PlanTrimestral>> call({
    PlanTrimestralFiltros? filtros,
  }) =>
      _repo.getPlanes(filtros: filtros);
}

class ObtenerPlanDetalleUseCase {
  final PlanificacionRepository _repo;
  const ObtenerPlanDetalleUseCase(this._repo);

  Future<PlanTrimestralDetalle> call(int id) => _repo.getPlanDetalle(id);
}

class CrearPlanUseCase {
  final PlanificacionRepository _repo;
  const CrearPlanUseCase(this._repo);

  Future<PlanTrimestralDetalle> call({
    required int      fichaId,
    required int      trimestre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) {
    if (trimestre <= 0) {
      throw const PlanificacionException('El trimestre debe ser mayor a 0.');
    }
    if (!fechaFin.isAfter(fechaInicio)) {
      throw const PlanificacionException(
          'La fecha de fin debe ser posterior a la de inicio.');
    }
    return _repo.crearPlan(
      fichaId:     fichaId,
      trimestre:   trimestre,
      fechaInicio: fechaInicio,
      fechaFin:    fechaFin,
    );
  }
}

class ActualizarFechasPlanUseCase {
  final PlanificacionRepository _repo;
  const ActualizarFechasPlanUseCase(this._repo);

  Future<PlanTrimestralDetalle> call(
    int planId, {
    DateTime?       fechaInicio,
    DateTime?       fechaFin,
    required DateTime currentInicio,
  }) {
    final inicio = fechaInicio ?? currentInicio;
    if (fechaFin != null && !fechaFin.isAfter(inicio)) {
      throw const PlanificacionException(
          'La fecha de fin debe ser posterior a la de inicio.');
    }
    return _repo.actualizarPlan(planId,
        fechaInicio: fechaInicio, fechaFin: fechaFin);
  }
}

class CambiarEstadoPlanUseCase {
  final PlanificacionRepository _repo;
  const CambiarEstadoPlanUseCase(this._repo);

  Future<PlanTrimestralDetalle> call(
    PlanTrimestralDetalle plan, {
    required EstadoPlan nuevoEstado,
    String?             motivoRechazo,
  }) {
    if (!plan.estado.transicionesValidas.contains(nuevoEstado)) {
      throw PlanificacionException(
        'No se puede pasar de "${plan.estado.label}" a "${nuevoEstado.label}".',
      );
    }
    if (nuevoEstado == EstadoPlan.aprobado && plan.items.isEmpty) {
      throw const PlanificacionException(
          'No se puede aprobar un plan sin ítems.');
    }
    if (nuevoEstado == EstadoPlan.rechazado &&
        (motivoRechazo == null || motivoRechazo.trim().isEmpty)) {
      throw const PlanificacionException('Debe indicar el motivo del rechazo.');
    }
    return _repo.cambiarEstado(plan.id,
        nuevoEstado: nuevoEstado, motivoRechazo: motivoRechazo);
  }
}

class GenerarHorarioUseCase {
  final PlanificacionRepository _repo;
  const GenerarHorarioUseCase(this._repo);

  Future<ResultadoGenerarHorario> call(PlanTrimestralDetalle plan) {
    if (plan.estado != EstadoPlan.aprobado) {
      throw const PlanificacionException(
          'El plan debe estar en estado Aprobado para generar horarios.');
    }
    return _repo.generarHorario(plan.id);
  }
}

class AutoGenerarPlanUseCase {
  final PlanificacionRepository _repo;
  const AutoGenerarPlanUseCase(this._repo);

  Future<ResultadoAutoGeneracion> call({
    required int      fichaId,
    required int      trimestre,
    DateTime?         fechaInicio,
    DateTime?         fechaFin,
  }) {
    if (trimestre <= 0) {
      throw const PlanificacionException('El trimestre debe ser mayor a 0.');
    }
    if (fechaInicio != null && fechaFin != null && !fechaFin.isAfter(fechaInicio)) {
      throw const PlanificacionException(
          'La fecha de fin debe ser posterior a la de inicio.');
    }
    return _repo.autoGenerarPlan(
      fichaId:     fichaId,
      trimestre:   trimestre,
      fechaInicio: fechaInicio,
      fechaFin:    fechaFin,
    );
  }
}
