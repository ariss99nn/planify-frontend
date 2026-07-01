// lib/features/aulas/presentation/providers/aula_provider.dart

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/api/api_service.dart';
import '../../data/repositories_impl/aula_repository_impl.dart';
import '../../data/repositories_impl/bloque_repository_impl.dart';
import '../../data/repositories_impl/equipamiento_repository_impl.dart';
import '../../domain/entities/aula_entity.dart';
import '../../domain/entities/bloque_entity.dart';
import '../../domain/entities/equipamiento_entity.dart';
import '../../domain/repositories/aula_repository.dart';
import '../../domain/repositories/bloque_repository.dart';
import '../../domain/repositories/equipamiento_repository.dart';
import '../../domain/usecases/aula/listar_aulas_usecase.dart';
import '../../domain/usecases/aula/obtener_aula_usecase.dart';
import '../../domain/usecases/aula/crear_aula_usecase.dart';
import '../../domain/usecases/aula/actualizar_aula_usecase.dart';
import '../../domain/usecases/aula/actualizar_estado_aula_usecase.dart';

enum AulaStatus { idle, loading, success, error }

class AulaProvider extends ChangeNotifier {
  late final ListarAulasUseCase         _listarAulas;
  late final ObtenerAulaUseCase         _obtenerAula;
  late final CrearAulaUseCase           _crearAula;
  late final ActualizarAulaUseCase      _actualizarAula;
  late final ActualizarEstadoAulaUseCase _actualizarEstado;

  final BloqueRepository       _bloqueRepo;
  final EquipamientoRepository _equipamientoRepo;

  AulaProvider({
    AulaRepository?           aulaRepository,
    BloqueRepository?         bloqueRepository,
    EquipamientoRepository?   equipamientoRepository,
  })  : _bloqueRepo       = bloqueRepository       ?? BloqueRepositoryImpl(),
        _equipamientoRepo = equipamientoRepository ?? EquipamientoRepositoryImpl() {
    final repo = aulaRepository ?? AulaRepositoryImpl();
    _listarAulas      = ListarAulasUseCase(repo);
    _obtenerAula      = ObtenerAulaUseCase(repo);
    _crearAula        = CrearAulaUseCase(repo);
    _actualizarAula   = ActualizarAulaUseCase(repo);
    _actualizarEstado = ActualizarEstadoAulaUseCase(repo);
  }

  // ── Lista ────────────────────────────────────────────────────────────────
  List<AulaResumenEntity> aulas = [];
  AulaStatus listStatus = AulaStatus.idle;
  String? listError;

  int _page = 1;
  bool hasMore = true;
  bool loadingMore = false;

  // ── Detalle ──────────────────────────────────────────────────────────────
  AulaEntity? selected;
  AulaStatus detailStatus = AulaStatus.idle;
  String? detailError;

  // ── Formulario ───────────────────────────────────────────────────────────
  AulaStatus formStatus = AulaStatus.idle;
  String? formError;

  // ── Bloques (dropdown) ───────────────────────────────────────────────────
  List<BloqueResumenEntity> bloques = [];
  AulaStatus bloquesStatus = AulaStatus.idle;

  // ── Equipamientos (multi-select) ─────────────────────────────────────────
  List<EquipamientoResumenEntity> equipamientos = [];
  AulaStatus equipamientosStatus = AulaStatus.idle;

  // ── Filtros ──────────────────────────────────────────────────────────────
  String? filtroSearch;
  String? filtroEstado;
  String? filtroTipo;
  int? filtroBloque;

  Future<void> fetchAulas() async {
    _page      = 1;
    hasMore    = true;
    listStatus = AulaStatus.loading;
    listError  = null;
    notifyListeners();
    try {
      final result = await _listarAulas(
        search:   filtroSearch,
        estado:   filtroEstado,
        tipoAula: filtroTipo,
        bloqueId: filtroBloque,
        page:     _page,
      );
      aulas      = result.items;
      hasMore    = result.hasNext;
      listStatus = AulaStatus.success;
    } catch (e) {
      listStatus = AulaStatus.error;
      listError  = _friendlyError(e);
    }
    notifyListeners();
  }

  /// Carga la siguiente página y la agrega al final de la lista (scroll infinito).
  Future<void> loadMoreAulas() async {
    if (loadingMore || !hasMore || listStatus != AulaStatus.success) return;
    loadingMore = true;
    notifyListeners();
    try {
      final nextPage = _page + 1;
      final result = await _listarAulas(
        search:   filtroSearch,
        estado:   filtroEstado,
        tipoAula: filtroTipo,
        bloqueId: filtroBloque,
        page:     nextPage,
      );
      _page   = nextPage;
      aulas   = [...aulas, ...result.items];
      hasMore = result.hasNext;
    } catch (_) {
      // Se conserva la lista actual.
    }
    loadingMore = false;
    notifyListeners();
  }

  void setFiltros({String? search, String? estado, String? tipo, int? bloque}) {
    filtroSearch = search;
    filtroEstado = estado;
    filtroTipo   = tipo;
    filtroBloque = bloque;
    fetchAulas();
  }

  void clearFiltros() => setFiltros();

  Future<void> fetchAula(int id) async {
    detailStatus = AulaStatus.loading;
    detailError  = null;
    notifyListeners();
    try {
      selected     = await _obtenerAula(id);
      detailStatus = AulaStatus.success;
    } catch (e) {
      detailStatus = AulaStatus.error;
      detailError  = _friendlyError(e);
    }
    notifyListeners();
  }

  Future<bool> createAula(
    Map<String, String> fields, {
    XFile? imagen,
    List<int> equipamientoIds = const [],
  }) async {
    formStatus = AulaStatus.loading;
    formError  = null;
    notifyListeners();
    try {
      await _crearAula(fields, imagen: imagen, equipamientoIds: equipamientoIds);
      formStatus = AulaStatus.success;
      await fetchAulas();
      notifyListeners();
      return true;
    } catch (e) {
      formStatus = AulaStatus.error;
      formError  = _friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAula(
    int id,
    Map<String, String> fields, {
    XFile? imagen,
    List<int> equipamientoIds = const [],
  }) async {
    formStatus = AulaStatus.loading;
    formError  = null;
    notifyListeners();
    try {
      selected   = await _actualizarAula(id, fields, imagen: imagen, equipamientoIds: equipamientoIds);
      formStatus = AulaStatus.success;
      await fetchAulas();
      notifyListeners();
      return true;
    } catch (e) {
      formStatus = AulaStatus.error;
      formError  = _friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEstado(int id, String estado) async {
    formStatus = AulaStatus.loading;
    formError  = null;
    notifyListeners();
    try {
      await _actualizarEstado(id, estado);
      formStatus = AulaStatus.success;
      if (selected?.id == id) await fetchAula(id);
      await fetchAulas();
      notifyListeners();
      return true;
    } catch (e) {
      formStatus = AulaStatus.error;
      formError  = _friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  /// Catálogo COMPLETO de bloques (todas las páginas) para el dropdown
  /// del formulario. Antes solo traía la página 1, lo que provocaba un
  /// crash al editar un aula cuyo bloque no estuviera en esa primera página.
  Future<void> fetchBloques() async {
    bloquesStatus = AulaStatus.loading;
    notifyListeners();
    try {
      bloques       = await _bloqueRepo.getAllBloques();
      bloquesStatus = AulaStatus.success;
    } catch (_) {
      bloquesStatus = AulaStatus.error;
    }
    notifyListeners();
  }

  /// Catálogo COMPLETO de equipamientos (todas las páginas) para el
  /// multi-select del formulario de aula.
  Future<void> fetchEquipamientos() async {
    equipamientosStatus = AulaStatus.loading;
    notifyListeners();
    try {
      equipamientos       = await _equipamientoRepo.getAllEquipamientos();
      equipamientosStatus = AulaStatus.success;
    } catch (_) {
      equipamientosStatus = AulaStatus.error;
    }
    notifyListeners();
  }

  void resetForm() {
    formStatus = AulaStatus.idle;
    formError  = null;
  }

  String _friendlyError(Object e) {
    if (e is ApiException) return e.message;
    return e.toString();
  }
}