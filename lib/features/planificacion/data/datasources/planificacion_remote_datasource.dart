// lib/features/planificacion/data/datasources/planificacion_remote_datasource.dart

import '../../../../core/api/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/plan_trimestral_entity.dart';
import '../models/plan_trimestral_model.dart';

class PlanificacionRemoteDatasource {
  Future<String?> _token() => TokenStorage.getAccessToken();

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  // ── Planes ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getPlanes({
    PlanTrimestralFiltros? filtros,
  }) async {
    final token = await _token();
    return await ApiService.get(
      '/planes/',
      token:       token,
      queryParams: filtros?.toQueryParams(),
    ) as Map<String, dynamic>;
  }

  Future<PlanTrimestralDetalleModel> getPlanDetalle(int id) async {
    final token = await _token();
    final data  = await ApiService.get('/planes/$id/', token: token)
        as Map<String, dynamic>;
    return PlanTrimestralDetalleModel.fromJson(data);
  }

  Future<PlanTrimestralDetalleModel> crearPlan({
    required int      fichaId,
    required int      trimestre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    final token = await _token();
    final data  = await ApiService.post(
      '/planes/create/',
      token: token,
      data: {
        'ficha':        fichaId,
        'trimestre':    trimestre,
        'fecha_inicio': _fmt(fechaInicio),
        'fecha_fin':    _fmt(fechaFin),
      },
    ) as Map<String, dynamic>;
    return PlanTrimestralDetalleModel.fromJson(data);
  }

  Future<PlanTrimestralDetalleModel> actualizarPlan(
    int id, {
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    final token = await _token();
    final data  = await ApiService.patch(
      '/planes/$id/update/',
      token: token,
      data: {
        if (fechaInicio != null) 'fecha_inicio': _fmt(fechaInicio),
        if (fechaFin    != null) 'fecha_fin':    _fmt(fechaFin),
      },
    ) as Map<String, dynamic>;
    return PlanTrimestralDetalleModel.fromJson(data);
  }

  Future<PlanTrimestralDetalleModel> cambiarEstado(
    int id, {
    required EstadoPlan nuevoEstado,
    String?             motivoRechazo,
  }) async {
    final token = await _token();
    final data  = await ApiService.patch(
      '/planes/$id/estado/',
      token: token,
      data: {
        'estado': nuevoEstado.toApiString(),
        if (motivoRechazo != null && motivoRechazo.isNotEmpty)
          'motivo_rechazo': motivoRechazo,
      },
    ) as Map<String, dynamic>;
    return PlanTrimestralDetalleModel.fromJson(data);
  }

  Future<ResultadoGenerarHorarioModel> generarHorario(int planId) async {
    final token = await _token();
    final data  = await ApiService.post(
      '/planes/$planId/generar-horario/',
      token: token,
    ) as Map<String, dynamic>;
    return ResultadoGenerarHorarioModel.fromJson(data);
  }

  Future<ResultadoAutoGeneracionModel> autoGenerarPlan({
    required int      fichaId,
    required int      trimestre,
    DateTime?         fechaInicio,
    DateTime?         fechaFin,
  }) async {
    final token = await _token();
    final data  = await ApiService.post(
      '/planes/auto-generar/',
      token: token,
      data: {
        'ficha':     fichaId,
        'trimestre': trimestre,
        if (fechaInicio != null) 'fecha_inicio': _fmt(fechaInicio),
        if (fechaFin    != null) 'fecha_fin':    _fmt(fechaFin),
      },
    ) as Map<String, dynamic>;
    return ResultadoAutoGeneracionModel.fromJson(data);
  }

  // ── Items ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getItems({ItemPlanFiltros? filtros}) async {
    final token = await _token();
    return await ApiService.get(
      '/items/',
      token:       token,
      queryParams: filtros?.toQueryParams(),
    ) as Map<String, dynamic>;
  }

  Future<ItemPlanModel> crearItem({
    required int planId,
    required int competenciaId,
    int?         docenteId,
    required int horasAsignadas,
    required int orden,
  }) async {
    final token = await _token();
    final data  = await ApiService.post(
      '/items/create/',
      token: token,
      data: {
        'plan':            planId,
        'competencia':     competenciaId,
        if (docenteId != null) 'docente': docenteId,
        'horas_asignadas': horasAsignadas,
        'orden':           orden,
      },
    ) as Map<String, dynamic>;
    return ItemPlanModel.fromJson(data);
  }

  Future<ItemPlanModel> actualizarItem(
    int id, {
    int?  docenteId,
    int?  horasAsignadas,
    int?  orden,
    bool? completado,
  }) async {
    final token = await _token();
    final data  = await ApiService.patch(
      '/items/$id/update/',
      token: token,
      data: {
        if (docenteId      != null) 'docente':          docenteId,
        if (horasAsignadas != null) 'horas_asignadas':  horasAsignadas,
        if (orden          != null) 'orden':            orden,
        if (completado     != null) 'completado':       completado,
      },
    ) as Map<String, dynamic>;
    return ItemPlanModel.fromJson(data);
  }

  // ── Bloques de competencia ─────────────────────────────────────────────────

  Future<List<BloqueCompetenciaModel>> getBloques({
    int? planId,
    int? itemId,
  }) async {
    final token  = await _token();
    final params = <String, String>{
      if (planId != null) 'plan': '$planId',
      if (itemId != null) 'item': '$itemId',
    };
    final data = await ApiService.get(
      '/bloques-competencia/',
      token:       token,
      queryParams: params.isNotEmpty ? params : null,
    ) as List<dynamic>;
    return data
        .map((e) => BloqueCompetenciaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BloqueCompetenciaModel> crearBloque({
    required int    bloqueId,
    required int    itemPlanId,
    required double horasEjecutadas,
    String          observaciones = '',
  }) async {
    final token = await _token();
    final data  = await ApiService.post(
      '/bloques-competencia/create/',
      token: token,
      data: {
        'bloque':           bloqueId,
        'item_plan':        itemPlanId,
        'horas_ejecutadas': horasEjecutadas,
        if (observaciones.isNotEmpty) 'observaciones': observaciones,
      },
    ) as Map<String, dynamic>;
    return BloqueCompetenciaModel.fromJson(data);
  }
}
