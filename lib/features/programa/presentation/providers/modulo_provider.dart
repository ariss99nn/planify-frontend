// lib/features/programa/presentation/providers/modulo_provider.dart
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_service.dart';
import '../../data/repositories_impl/modulo_repository_impl.dart';
import '../../domain/entities/modulo_entity.dart';
import '../../domain/repositories/modulo_repository.dart';
import '../../domain/usecases/modulo/listar_modulos_usecase.dart';
import '../../domain/usecases/modulo/obtener_modulo_usecase.dart';
import '../../domain/usecases/modulo/crear_modulo_usecase.dart';
import '../../domain/usecases/modulo/actualizar_modulo_usecase.dart';

class ModuloProvider extends ChangeNotifier {
  late final ListarModulosUseCase _listarModulos;
  late final ObtenerModuloUseCase _obtenerModulo;
  late final CrearModuloUseCase _crearModulo;
  late final ActualizarModuloUseCase _actualizarModulo;

  ModuloProvider({ModuloRepository? repository}) {
    final repo = repository ?? ModuloRepositoryImpl();
    _listarModulos = ListarModulosUseCase(repo);
    _obtenerModulo = ObtenerModuloUseCase(repo);
    _crearModulo = CrearModuloUseCase(repo);
    _actualizarModulo = ActualizarModuloUseCase(repo);
  }

  // ── Listado ──────────────────────────────────────────────────────────
  final List<ModuloResumenEntity> _items = [];
  List<ModuloResumenEntity> get items => List.unmodifiable(_items);

  bool isLoadingList = false;
  String? listError;

  int _page = 1;
  bool _hasNext = false;
  bool get hasNext => _hasNext;

  String? search;
  int? filtroVersionId;
  ModuloEstado? filtroEstado;

  Future<void> fetchList({bool reset = true}) async {
    if (reset) _page = 1;
    isLoadingList = true;
    listError = null;
    notifyListeners();

    try {
      final response = await _listarModulos(
        page: _page,
        search: search,
        versionId: filtroVersionId,
        estado: filtroEstado,
      );
      if (reset) _items.clear();
      _items.addAll(response.results);
      _hasNext = response.hasNext;
    } on ApiException catch (e) {
      listError = e.message;
    } finally {
      isLoadingList = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!_hasNext || isLoadingList) return;
    _page += 1;
    await fetchList(reset: false);
  }

  void setFiltros({String? search, int? versionId, ModuloEstado? estado}) {
    this.search = search;
    filtroVersionId = versionId;
    filtroEstado = estado;
    fetchList(reset: true);
  }

  // ── Detalle ──────────────────────────────────────────────────────────
  ModuloEntity? selected;
  bool isLoadingDetail = false;
  String? detailError;

  Future<void> fetchDetail(int id) async {
    isLoadingDetail = true;
    detailError = null;
    notifyListeners();
    try {
      selected = await _obtenerModulo(id);
    } on ApiException catch (e) {
      detailError = e.message;
    } finally {
      isLoadingDetail = false;
      notifyListeners();
    }
  }

  // ── Crear / Actualizar ───────────────────────────────────────────────
  bool isSaving = false;
  String? saveError;

  Future<ModuloEntity?> create({
    required int versionId,
    required String nombre,
    String descripcion = '',
    required int orden,
    required int horasLectivas,
    required int horasPracticas,
    ModuloEstado estado = ModuloEstado.activo,
  }) async {
    isSaving = true;
    saveError = null;
    notifyListeners();
    try {
      final modulo = await _crearModulo(
        versionId: versionId,
        nombre: nombre,
        descripcion: descripcion,
        orden: orden,
        horasLectivas: horasLectivas,
        horasPracticas: horasPracticas,
        estado: estado,
      );
      // Un módulo recién creado no puede tener asignaturas todavía: 0 es exacto.
      _items.insert(
          0, ModuloResumenEntity.fromDetail(modulo, totalAsignaturas: 0));
      return modulo;
    } on ApiException catch (e) {
      saveError = e.message;
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<ModuloEntity?> update({
    required int id,
    String? nombre,
    String? descripcion,
    int? orden,
    int? horasLectivas,
    int? horasPracticas,
    ModuloEstado? estado,
  }) async {
    isSaving = true;
    saveError = null;
    notifyListeners();
    try {
      final modulo = await _actualizarModulo(
        id: id,
        nombre: nombre,
        descripcion: descripcion,
        orden: orden,
        horasLectivas: horasLectivas,
        horasPracticas: horasPracticas,
        estado: estado,
      );
      selected = modulo;
      final index = _items.indexWhere((m) => m.id == id);
      if (index != -1) {
        // Conserva totalAsignaturas, que no viene en el detalle.
        final totalAsignaturas = _items[index].totalAsignaturas;
        _items[index] = ModuloResumenEntity.fromDetail(modulo,
            totalAsignaturas: totalAsignaturas);
      }
      return modulo;
    } on ApiException catch (e) {
      saveError = e.message;
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
