// lib/features/programa/presentation/providers/version_provider.dart
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_service.dart';
import '../../data/repositories_impl/version_repository_impl.dart';
import '../../domain/entities/version_programa_entity.dart';
import '../../domain/repositories/version_repository.dart';
import '../../domain/usecases/version/listar_versiones_usecase.dart';
import '../../domain/usecases/version/obtener_version_usecase.dart';
import '../../domain/usecases/version/crear_version_usecase.dart';
import '../../domain/usecases/version/actualizar_version_usecase.dart';

class VersionProvider extends ChangeNotifier {
  late final ListarVersionesUseCase _listarVersiones;
  late final ObtenerVersionUseCase _obtenerVersion;
  late final CrearVersionUseCase _crearVersion;
  late final ActualizarVersionUseCase _actualizarVersion;

  VersionProvider({VersionRepository? repository}) {
    final repo = repository ?? VersionRepositoryImpl();
    _listarVersiones = ListarVersionesUseCase(repo);
    _obtenerVersion = ObtenerVersionUseCase(repo);
    _crearVersion = CrearVersionUseCase(repo);
    _actualizarVersion = ActualizarVersionUseCase(repo);
  }

  // ── Listado ──────────────────────────────────────────────────────────
  final List<VersionResumenEntity> _items = [];
  List<VersionResumenEntity> get items => List.unmodifiable(_items);

  bool isLoadingList = false;
  String? listError;

  int _page = 1;
  bool _hasNext = false;
  bool get hasNext => _hasNext;

  String? search;
  int? filtroProgramaId;
  bool? filtroVigente;

  Future<void> fetchList({bool reset = true}) async {
    if (reset) _page = 1;
    isLoadingList = true;
    listError = null;
    notifyListeners();

    try {
      final response = await _listarVersiones(
        page: _page,
        search: search,
        programaId: filtroProgramaId,
        vigente: filtroVigente,
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

  void setFiltros({String? search, int? programaId, bool? vigente}) {
    this.search = search;
    filtroProgramaId = programaId;
    filtroVigente = vigente;
    fetchList(reset: true);
  }

  // ── Detalle ──────────────────────────────────────────────────────────
  VersionEntity? selected;
  bool isLoadingDetail = false;
  String? detailError;

  Future<void> fetchDetail(int id) async {
    isLoadingDetail = true;
    detailError = null;
    notifyListeners();
    try {
      selected = await _obtenerVersion(id);
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

  void _sincronizarVigencia(VersionEntity version) {
    if (!version.vigente) return;
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.id != version.id &&
          item.vigente &&
          item.programaId == version.programa.id) {
        _items[i] = item.copyWith(vigente: false);
      }
    }
  }

  Future<VersionEntity?> create({
    required int programaId,
    required int numero,
    String descripcion = '',
    bool vigente = false,
    required DateTime fechaInicio,
    DateTime? fechaFin,
  }) async {
    isSaving = true;
    saveError = null;
    notifyListeners();
    try {
      final version = await _crearVersion(
        programaId: programaId,
        numero: numero,
        descripcion: descripcion,
        vigente: vigente,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      _sincronizarVigencia(version);
      _items.insert(0, VersionResumenEntity.fromDetail(version));
      return version;
    } on ApiException catch (e) {
      saveError = e.message;
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<VersionEntity?> update({
    required int id,
    String? descripcion,
    bool? vigente,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    isSaving = true;
    saveError = null;
    notifyListeners();
    try {
      final version = await _actualizarVersion(
        id: id,
        descripcion: descripcion,
        vigente: vigente,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      selected = version;
      _sincronizarVigencia(version);
      final index = _items.indexWhere((v) => v.id == id);
      if (index != -1) {
        _items[index] = VersionResumenEntity.fromDetail(version);
      }
      return version;
    } on ApiException catch (e) {
      saveError = e.message;
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
