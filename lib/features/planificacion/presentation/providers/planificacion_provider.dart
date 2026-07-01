// lib/features/planificacion/presentation/providers/planificacion_provider.dart

import 'package:flutter/foundation.dart';

import '../../../../core/api/api_service.dart';
import '../../data/repositories_impl/planificacion_repository_impl.dart';
import '../../domain/entities/plan_trimestral_entity.dart';
import '../../domain/repositories/planificacion_repository.dart';
import '../../domain/usecases/bloque_usecases.dart';
import '../../domain/usecases/item_usecases.dart';
import '../../domain/usecases/plan_usecases.dart';

class PlanificacionProvider extends ChangeNotifier {
  // ── Use cases ──────────────────────────────────────────────────────────────
  final CargarPlanesUseCase       _cargarPlanes;
  final ObtenerPlanDetalleUseCase _obtenerDetalle;
  final CrearPlanUseCase          _crearPlan;
  final ActualizarFechasPlanUseCase _actualizarFechas;
  final CambiarEstadoPlanUseCase  _cambiarEstadoUC;
  final GenerarHorarioUseCase     _generarHorario;
  final CargarItemsUseCase        _cargarItems;
  final CrearItemUseCase          _crearItem;
  final ActualizarItemUseCase     _actualizarItem;
  final CargarBloquesUseCase      _cargarBloques;
  final CrearBloqueUseCase        _crearBloque;

  factory PlanificacionProvider({PlanificacionRepository? repo}) {
    final r = repo ?? PlanificacionRepositoryImpl();
    return PlanificacionProvider._(
      CargarPlanesUseCase(r),
      ObtenerPlanDetalleUseCase(r),
      CrearPlanUseCase(r),
      ActualizarFechasPlanUseCase(r),
      CambiarEstadoPlanUseCase(r),
      GenerarHorarioUseCase(r),
      CargarItemsUseCase(r),
      CrearItemUseCase(r),
      ActualizarItemUseCase(r),
      CargarBloquesUseCase(r),
      CrearBloqueUseCase(r),
    );
  }

  PlanificacionProvider._(
    this._cargarPlanes,
    this._obtenerDetalle,
    this._crearPlan,
    this._actualizarFechas,
    this._cambiarEstadoUC,
    this._generarHorario,
    this._cargarItems,
    this._crearItem,
    this._actualizarItem,
    this._cargarBloques,
    this._crearBloque,
  );

  // ── Estado lista ──────────────────────────────────────────────────────────
  List<PlanTrimestral> _planes       = [];
  int                  _planesCount  = 0;
  bool                 _hasMorePlanes = false;
  bool                 _isLoadingList = false;

  List<PlanTrimestral> get planes        => _planes;
  int                  get planesCount   => _planesCount;
  bool                 get hasMorePlanes => _hasMorePlanes;
  bool                 get isLoadingList => _isLoadingList;

  // ── Estado detalle ────────────────────────────────────────────────────────
  PlanTrimestralDetalle? _selectedPlan;
  bool                   _isLoadingDetail = false;

  PlanTrimestralDetalle? get selectedPlan    => _selectedPlan;
  bool                   get isLoadingDetail => _isLoadingDetail;

  // ── Estado items ──────────────────────────────────────────────────────────
  List<ItemPlan> _items          = [];
  bool           _isLoadingItems = false;

  List<ItemPlan> get items          => _items;
  bool           get isLoadingItems => _isLoadingItems;

  // ── Estado bloques ────────────────────────────────────────────────────────
  List<BloqueCompetencia> _bloques          = [];
  bool                    _isLoadingBloques = false;

  List<BloqueCompetencia> get bloques          => _bloques;
  bool                    get isLoadingBloques => _isLoadingBloques;

  // ── Estado acciones ───────────────────────────────────────────────────────
  bool    _isSubmitting = false;
  bool    get isSubmitting => _isSubmitting;

  // ── Error ─────────────────────────────────────────────────────────────────
  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Planes
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> cargarPlanes({
    PlanTrimestralFiltros? filtros,
    bool reset = true,
  }) async {
    if (reset) _planes = [];
    _isLoadingList = true;
    _error         = null;
    notifyListeners();

    try {
      final result  = await _cargarPlanes(filtros: filtros);
      _planes        = reset ? result.results : [..._planes, ...result.results];
      _planesCount   = result.count;
      _hasMorePlanes = result.hasMore;
    } catch (e) {
      _error = _friendlyError(e);
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  Future<void> cargarDetallePlan(int id) async {
    _isLoadingDetail = true;
    _error           = null;
    notifyListeners();

    try {
      _selectedPlan = await _obtenerDetalle(id);
    } catch (e) {
      _error = _friendlyError(e);
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<PlanTrimestralDetalle?> crearPlan({
    required int      fichaId,
    required int      trimestre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    _isSubmitting = true;
    _error        = null;
    notifyListeners();

    try {
      final nuevo   = await _crearPlan(
        fichaId:     fichaId,
        trimestre:   trimestre,
        fechaInicio: fechaInicio,
        fechaFin:    fechaFin,
      );
      _selectedPlan = nuevo;
      _planes       = [nuevo, ..._planes];
      return nuevo;
    } catch (e) {
      _error = _friendlyError(e);
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarFechas(
    int planId, {
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    if (_selectedPlan == null) return false;
    _isSubmitting = true;
    _error        = null;
    notifyListeners();

    try {
      final actualizado = await _actualizarFechas(
        planId,
        fechaInicio:   fechaInicio,
        fechaFin:      fechaFin,
        currentInicio: _selectedPlan!.fechaInicio,
      );
      _selectedPlan = actualizado;
      _syncPlanInList(actualizado);
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> cambiarEstado(
    EstadoPlan nuevoEstado, {
    String? motivoRechazo,
  }) async {
    if (_selectedPlan == null) return false;
    _isSubmitting = true;
    _error        = null;
    notifyListeners();

    try {
      final actualizado = await _cambiarEstadoUC(
        _selectedPlan!,
        nuevoEstado:   nuevoEstado,
        motivoRechazo: motivoRechazo,
      );
      _selectedPlan = actualizado;
      _syncPlanInList(actualizado);
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<ResultadoGenerarHorario?> generarHorario() async {
    if (_selectedPlan == null) return null;
    _isSubmitting = true;
    _error        = null;
    notifyListeners();

    try {
      return await _generarHorario(_selectedPlan!);
    } catch (e) {
      _error = _friendlyError(e);
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Items
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> cargarItems({ItemPlanFiltros? filtros}) async {
    _isLoadingItems = true;
    _error          = null;
    notifyListeners();

    try {
      final result = await _cargarItems(filtros: filtros);
      _items       = result.results;
    } catch (e) {
      _error = _friendlyError(e);
    } finally {
      _isLoadingItems = false;
      notifyListeners();
    }
  }

  Future<ItemPlan?> crearItem({
    required int planId,
    required int competenciaId,
    int?         docenteId,
    required int horasAsignadas,
    required int orden,
  }) async {
    _isSubmitting = true;
    _error        = null;
    notifyListeners();

    try {
      final item = await _crearItem(
        planId:         planId,
        competenciaId:  competenciaId,
        docenteId:      docenteId,
        horasAsignadas: horasAsignadas,
        orden:          orden,
      );
      _items = [..._items, item];
      if (_selectedPlan != null && _selectedPlan!.id == planId) {
        _selectedPlan = _selectedPlan!.withItems([..._selectedPlan!.items, item]);
      }
      return item;
    } catch (e) {
      _error = _friendlyError(e);
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarItem(
    int itemId, {
    int?  docenteId,
    int?  horasAsignadas,
    int?  orden,
    bool? completado,
  }) async {
    _isSubmitting = true;
    _error        = null;
    notifyListeners();

    try {
      final actualizado = await _actualizarItem(
        itemId,
        docenteId:      docenteId,
        horasAsignadas: horasAsignadas,
        orden:          orden,
        completado:     completado,
      );
      _items = _items.map((i) => i.id == itemId ? actualizado : i).toList();
      if (_selectedPlan != null) {
        _selectedPlan = _selectedPlan!.withItems(
          _selectedPlan!.items.map((i) => i.id == itemId ? actualizado : i).toList(),
        );
      }
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Bloques de competencia
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> cargarBloques({int? planId, int? itemId}) async {
    _isLoadingBloques = true;
    _error            = null;
    notifyListeners();

    try {
      _bloques = await _cargarBloques(planId: planId, itemId: itemId);
    } catch (e) {
      _error = _friendlyError(e);
    } finally {
      _isLoadingBloques = false;
      notifyListeners();
    }
  }

  Future<BloqueCompetencia?> crearBloque({
    required int    bloqueId,
    required int    itemPlanId,
    required double horasEjecutadas,
    String          observaciones = '',
  }) async {
    _isSubmitting = true;
    _error        = null;
    notifyListeners();

    try {
      final bloque = await _crearBloque(
        bloqueId:        bloqueId,
        itemPlanId:      itemPlanId,
        horasEjecutadas: horasEjecutadas,
        observaciones:   observaciones,
      );
      _bloques = [..._bloques, bloque];
      return bloque;
    } catch (e) {
      _error = _friendlyError(e);
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ── Utilidades internas ───────────────────────────────────────────────────

  void _syncPlanInList(PlanTrimestralDetalle actualizado) {
    _planes = _planes
        .map((p) => p.id == actualizado.id ? actualizado : p)
        .toList();
  }

  String _friendlyError(Object e) {
    if (e is PlanificacionException) return e.message;
    if (e is ApiException) return e.message;
    return 'Error inesperado. Intenta de nuevo.';
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void reset() {
    _planes           = [];
    _planesCount      = 0;
    _hasMorePlanes    = false;
    _selectedPlan     = null;
    _items            = [];
    _bloques          = [];
    _error            = null;
    _isLoadingList    = false;
    _isLoadingDetail  = false;
    _isLoadingItems   = false;
    _isLoadingBloques = false;
    _isSubmitting     = false;
    notifyListeners();
  }
}
