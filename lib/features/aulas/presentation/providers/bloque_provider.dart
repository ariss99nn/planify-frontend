// lib/features/aulas/presentation/providers/bloque_provider.dart

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/api/api_service.dart';
import '../../data/repositories_impl/bloque_repository_impl.dart';
import '../../domain/entities/bloque_entity.dart';
import '../../domain/repositories/bloque_repository.dart';
import '../../domain/usecases/bloque/listar_bloques_usecase.dart';
import '../../domain/usecases/bloque/obtener_bloque_usecase.dart';
import '../../domain/usecases/bloque/crear_bloque_usecase.dart';
import '../../domain/usecases/bloque/actualizar_bloque_usecase.dart';

enum BloqueStatus { idle, loading, success, error }

class BloqueProvider extends ChangeNotifier {
  late final ListarBloquesUseCase    _listarBloques;
  late final ObtenerBloqueUseCase    _obtenerBloque;
  late final CrearBloqueUseCase      _crearBloque;
  late final ActualizarBloqueUseCase _actualizarBloque;

  BloqueProvider({BloqueRepository? repository}) {
    final repo        = repository ?? BloqueRepositoryImpl();
    _listarBloques    = ListarBloquesUseCase(repo);
    _obtenerBloque    = ObtenerBloqueUseCase(repo);
    _crearBloque      = CrearBloqueUseCase(repo);
    _actualizarBloque = ActualizarBloqueUseCase(repo);
  }

  // ── Lista ────────────────────────────────────────────────────────────────
  List<BloqueResumenEntity> bloques = [];
  BloqueStatus listStatus = BloqueStatus.idle;
  String? listError;

  int _page = 1;
  bool hasMore = true;
  bool loadingMore = false;

  BloqueDetalleEntity? selected;
  BloqueStatus detailStatus = BloqueStatus.idle;
  String? detailError;

  BloqueStatus formStatus = BloqueStatus.idle;
  String? formError;

  String? filtroSearch;
  String? filtroEstado;

  Future<void> fetchBloques() async {
    _page      = 1;
    hasMore    = true;
    listStatus = BloqueStatus.loading;
    listError  = null;
    notifyListeners();
    try {
      final result = await _listarBloques(search: filtroSearch, estado: filtroEstado, page: _page);
      bloques    = result.items;
      hasMore    = result.hasNext;
      listStatus = BloqueStatus.success;
    } catch (e) {
      listStatus = BloqueStatus.error;
      listError  = _friendlyError(e);
    }
    notifyListeners();
  }

  /// Carga la siguiente página y la agrega al final de la lista (scroll infinito).
  Future<void> loadMoreBloques() async {
    if (loadingMore || !hasMore || listStatus != BloqueStatus.success) return;
    loadingMore = true;
    notifyListeners();
    try {
      final nextPage = _page + 1;
      final result = await _listarBloques(search: filtroSearch, estado: filtroEstado, page: nextPage);
      _page   = nextPage;
      bloques = [...bloques, ...result.items];
      hasMore = result.hasNext;
    } catch (_) {
      // Se conserva la lista actual; el usuario puede reintentar haciendo scroll de nuevo.
    }
    loadingMore = false;
    notifyListeners();
  }

  void setFiltros({String? search, String? estado}) {
    filtroSearch = search;
    filtroEstado = estado;
    fetchBloques();
  }

  void clearFiltros() => setFiltros();

  Future<void> fetchBloque(int id) async {
    detailStatus = BloqueStatus.loading;
    detailError  = null;
    notifyListeners();
    try {
      selected     = await _obtenerBloque(id);
      detailStatus = BloqueStatus.success;
    } catch (e) {
      detailStatus = BloqueStatus.error;
      detailError  = _friendlyError(e);
    }
    notifyListeners();
  }

  Future<bool> createBloque(Map<String, String> fields, {XFile? imagen}) async {
    formStatus = BloqueStatus.loading;
    formError  = null;
    notifyListeners();
    try {
      await _crearBloque(fields, imagen: imagen);
      formStatus = BloqueStatus.success;
      await fetchBloques();
      notifyListeners();
      return true;
    } catch (e) {
      formStatus = BloqueStatus.error;
      formError  = _friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBloque(int id, Map<String, String> fields, {XFile? imagen}) async {
    formStatus = BloqueStatus.loading;
    formError  = null;
    notifyListeners();
    try {
      selected   = await _actualizarBloque(id, fields, imagen: imagen);
      formStatus = BloqueStatus.success;
      await fetchBloques();
      notifyListeners();
      return true;
    } catch (e) {
      formStatus = BloqueStatus.error;
      formError  = _friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  void resetForm() {
    formStatus = BloqueStatus.idle;
    formError  = null;
  }

  String _friendlyError(Object e) {
    if (e is ApiException) return e.message;
    return e.toString();
  }
}