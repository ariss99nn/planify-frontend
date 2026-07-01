// lib/features/programa/presentation/providers/programa_provider.dart
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_service.dart';
import '../../data/repositories_impl/programa_repository_impl.dart';
import '../../domain/entities/programa_entity.dart';
import '../../domain/repositories/programa_repository.dart';
import '../../domain/usecases/programa/listar_programas_usecase.dart';
import '../../domain/usecases/programa/obtener_programa_usecase.dart';
import '../../domain/usecases/programa/crear_programa_usecase.dart';
import '../../domain/usecases/programa/actualizar_programa_usecase.dart';

class ProgramaProvider extends ChangeNotifier {
  late final ListarProgramasUseCase _listarProgramas;
  late final ObtenerProgramaUseCase _obtenerPrograma;
  late final CrearProgramaUseCase _crearPrograma;
  late final ActualizarProgramaUseCase _actualizarPrograma;

  ProgramaProvider({ProgramaRepository? repository}) {
    final repo = repository ?? ProgramaRepositoryImpl();
    _listarProgramas = ListarProgramasUseCase(repo);
    _obtenerPrograma = ObtenerProgramaUseCase(repo);
    _crearPrograma = CrearProgramaUseCase(repo);
    _actualizarPrograma = ActualizarProgramaUseCase(repo);
  }

  // ── Listado ──────────────────────────────────────────────────────────
  final List<ProgramaResumenEntity> _items = [];
  List<ProgramaResumenEntity> get items => List.unmodifiable(_items);

  bool isLoadingList = false;
  String? listError;

  int _page = 1;
  bool _hasNext = false;
  bool get hasNext => _hasNext;

  String? search;
  ProgramaNivel? filtroNivel;
  ProgramaEstado? filtroEstado;

  Future<void> fetchList({bool reset = true}) async {
    if (reset) _page = 1;
    isLoadingList = true;
    listError = null;
    notifyListeners();

    try {
      final response = await _listarProgramas(
        page: _page,
        search: search,
        nivel: filtroNivel,
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

  void setFiltros({String? search, ProgramaNivel? nivel, ProgramaEstado? estado}) {
    this.search = search;
    filtroNivel = nivel;
    filtroEstado = estado;
    fetchList(reset: true);
  }

  // ── Detalle ──────────────────────────────────────────────────────────
  ProgramaEntity? selected;
  bool isLoadingDetail = false;
  String? detailError;

  Future<void> fetchDetail(int id) async {
    isLoadingDetail = true;
    detailError = null;
    notifyListeners();
    try {
      selected = await _obtenerPrograma(id);
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

  Future<ProgramaEntity?> create({
    required String nombre,
    String descripcion = '',
    required ProgramaNivel nivel,
    required int horasLectivas,
    required int horasPracticas,
    ProgramaEstado estado = ProgramaEstado.activo,
    int trimestresTotales = 6,
    ProgramaTipoFormacion tipoFormacion = ProgramaTipoFormacion.porOferta,
    int? trimestresCadena,
  }) async {
    isSaving = true;
    saveError = null;
    notifyListeners();
    try {
      final programa = await _crearPrograma(
        nombre: nombre,
        descripcion: descripcion,
        nivel: nivel,
        horasLectivas: horasLectivas,
        horasPracticas: horasPracticas,
        estado: estado,
        trimestresTotales: trimestresTotales,
        tipoFormacion: tipoFormacion,
        trimestresCadena: trimestresCadena,
      );
      _items.insert(0, ProgramaResumenEntity.fromDetail(programa));
      return programa;
    } on ApiException catch (e) {
      saveError = e.message;
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<ProgramaEntity?> update({
    required int id,
    String? nombre,
    String? descripcion,
    ProgramaNivel? nivel,
    int? horasLectivas,
    int? horasPracticas,
    ProgramaEstado? estado,
    int? trimestresTotales,
    ProgramaTipoFormacion? tipoFormacion,
    int? trimestresCadena,
  }) async {
    isSaving = true;
    saveError = null;
    notifyListeners();
    try {
      final programa = await _actualizarPrograma(
        id: id,
        nombre: nombre,
        descripcion: descripcion,
        nivel: nivel,
        horasLectivas: horasLectivas,
        horasPracticas: horasPracticas,
        estado: estado,
        trimestresTotales: trimestresTotales,
        tipoFormacion: tipoFormacion,
        trimestresCadena: trimestresCadena,
      );
      selected = programa;
      final index = _items.indexWhere((p) => p.id == id);
      if (index != -1) {
        _items[index] = ProgramaResumenEntity.fromDetail(programa);
      }
      return programa;
    } on ApiException catch (e) {
      saveError = e.message;
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
