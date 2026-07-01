// lib/features/aulas/presentation/providers/equipamiento_provider.dart

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/api/api_service.dart';
import '../../data/repositories_impl/equipamiento_repository_impl.dart';
import '../../domain/entities/equipamiento_entity.dart';
import '../../domain/repositories/equipamiento_repository.dart';
import '../../domain/usecases/equipamiento/listar_equipamientos_usecase.dart';
import '../../domain/usecases/equipamiento/obtener_equipamiento_usecase.dart';
import '../../domain/usecases/equipamiento/crear_equipamiento_usecase.dart';
import '../../domain/usecases/equipamiento/actualizar_equipamiento_usecase.dart';

enum EquipamientoStatus { idle, loading, success, error }

class EquipamientoProvider extends ChangeNotifier {
  late final ListarEquipamientosUseCase    _listarEquipamientos;
  late final ObtenerEquipamientoUseCase    _obtenerEquipamiento;
  late final CrearEquipamientoUseCase      _crearEquipamiento;
  late final ActualizarEquipamientoUseCase _actualizarEquipamiento;

  EquipamientoProvider({EquipamientoRepository? repository}) {
    final repo              = repository ?? EquipamientoRepositoryImpl();
    _listarEquipamientos    = ListarEquipamientosUseCase(repo);
    _obtenerEquipamiento    = ObtenerEquipamientoUseCase(repo);
    _crearEquipamiento      = CrearEquipamientoUseCase(repo);
    _actualizarEquipamiento = ActualizarEquipamientoUseCase(repo);
  }

  List<EquipamientoResumenEntity> equipamientos = [];
  EquipamientoStatus listStatus = EquipamientoStatus.idle;
  String? listError;

  int _page = 1;
  bool hasMore = true;
  bool loadingMore = false;

  EquipamientoDetalleEntity? selected;
  EquipamientoStatus detailStatus = EquipamientoStatus.idle;
  String? detailError;

  EquipamientoStatus formStatus = EquipamientoStatus.idle;
  String? formError;

  String? filtroSearch;
  String? filtroEstado;

  Future<void> fetchEquipamientos() async {
    _page      = 1;
    hasMore    = true;
    listStatus = EquipamientoStatus.loading;
    listError  = null;
    notifyListeners();
    try {
      final result = await _listarEquipamientos(search: filtroSearch, estado: filtroEstado, page: _page);
      equipamientos = result.items;
      hasMore       = result.hasNext;
      listStatus    = EquipamientoStatus.success;
    } catch (e) {
      listStatus = EquipamientoStatus.error;
      listError  = _friendlyError(e);
    }
    notifyListeners();
  }

  /// Carga la siguiente página y la agrega al final de la lista (scroll infinito).
  Future<void> loadMoreEquipamientos() async {
    if (loadingMore || !hasMore || listStatus != EquipamientoStatus.success) return;
    loadingMore = true;
    notifyListeners();
    try {
      final nextPage = _page + 1;
      final result = await _listarEquipamientos(search: filtroSearch, estado: filtroEstado, page: nextPage);
      _page         = nextPage;
      equipamientos = [...equipamientos, ...result.items];
      hasMore       = result.hasNext;
    } catch (_) {
      // Se conserva la lista actual.
    }
    loadingMore = false;
    notifyListeners();
  }

  void setFiltros({String? search, String? estado}) {
    filtroSearch = search;
    filtroEstado = estado;
    fetchEquipamientos();
  }

  void clearFiltros() => setFiltros();

  Future<void> fetchEquipamiento(int id) async {
    detailStatus = EquipamientoStatus.loading;
    detailError  = null;
    notifyListeners();
    try {
      selected     = await _obtenerEquipamiento(id);
      detailStatus = EquipamientoStatus.success;
    } catch (e) {
      detailStatus = EquipamientoStatus.error;
      detailError  = _friendlyError(e);
    }
    notifyListeners();
  }

  Future<bool> createEquipamiento(Map<String, String> fields, {XFile? imagen}) async {
    formStatus = EquipamientoStatus.loading;
    formError  = null;
    notifyListeners();
    try {
      await _crearEquipamiento(fields, imagen: imagen);
      formStatus = EquipamientoStatus.success;
      await fetchEquipamientos();
      notifyListeners();
      return true;
    } catch (e) {
      formStatus = EquipamientoStatus.error;
      formError  = _friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEquipamiento(int id, Map<String, String> fields, {XFile? imagen}) async {
    formStatus = EquipamientoStatus.loading;
    formError  = null;
    notifyListeners();
    try {
      selected   = await _actualizarEquipamiento(id, fields, imagen: imagen);
      formStatus = EquipamientoStatus.success;
      await fetchEquipamientos();
      notifyListeners();
      return true;
    } catch (e) {
      formStatus = EquipamientoStatus.error;
      formError  = _friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  void resetForm() {
    formStatus = EquipamientoStatus.idle;
    formError  = null;
  }

  String _friendlyError(Object e) {
    if (e is ApiException) return e.message;
    return e.toString();
  }
}