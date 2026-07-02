import 'package:flutter/foundation.dart';

import '../../data/models/competencia_model.dart';
import '../../data/repositories_impl/competencia_repository_impl.dart';
import '../../domain/repositories/competencia_repository.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/api/api_service.dart';

class CompetenciaProvider extends ChangeNotifier {
  CompetenciaProvider({CompetenciaRepository? repo})
      : _repo = repo ?? const CompetenciaRepositoryImpl();

  final CompetenciaRepository _repo;

  List<CompetenciaItem> _items     = [];
  bool                  _isLoading = false;
  String?               _error;
  int                   _page      = 1;
  int                   _total     = 0;
  bool                  _hasNext   = false;
  bool                  _hasPrev   = false;

  String _search       = '';
  String _tipo         = '';
  int?   _asignaturaId;

  CompetenciaItem? _detail;
  bool             _isLoadingDetail = false;
  String?          _detailError;

  bool    _isSaving   = false;
  bool    _isDeleting = false;
  String? _saveError;

  List<CompetenciaItem> get items           => _items;
  bool                  get isLoading       => _isLoading;
  String?               get error           => _error;
  int                   get currentPage     => _page;
  int                   get totalCount      => _total;
  bool                  get hasNext         => _hasNext;
  bool                  get hasPrevious     => _hasPrev;
  String                get search          => _search;
  String                get tipo            => _tipo;
  int?                  get asignaturaId    => _asignaturaId;
  CompetenciaItem?      get detail          => _detail;
  bool                  get isLoadingDetail => _isLoadingDetail;
  String?               get detailError     => _detailError;
  bool                  get isSaving        => _isSaving;
  bool                  get isDeleting      => _isDeleting;
  String?               get saveError       => _saveError;

  Future<void> loadPage({int page = 1}) async {
    _isLoading = true;
    _error     = null;
    _page      = page;
    notifyListeners();

    try {
      final PaginatedResponse<CompetenciaItem> res = await _repo.list(
        search:     _search,
        tipo:       _tipo,
        asignatura: _asignaturaId,
        page:       page,
      );
      _items   = res.results;
      _total   = res.count;
      _hasNext = res.hasNext;
      _hasPrev = res.hasPrevious;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Error de conexión. Verifica tu red.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearch(String v)     { _search       = v; loadPage(); }
  void setTipo(String v)       { _tipo         = v; loadPage(); }
  void setAsignaturaId(int? v) { _asignaturaId = v; loadPage(); }

  void clearFilters() {
    _search       = '';
    _tipo         = '';
    _asignaturaId = null;
    loadPage();
  }

  void nextPage()     { if (_hasNext) loadPage(page: _page + 1); }
  void previousPage() { if (_hasPrev) loadPage(page: _page - 1); }

  Future<void> loadDetail(int id) async {
    _isLoadingDetail = true;
    _detailError     = null;
    _detail          = null;
    notifyListeners();

    try {
      _detail = await _repo.get(id);
    } on ApiException catch (e) {
      _detailError = e.message;
    } catch (_) {
      _detailError = 'Error de conexión.';
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<CompetenciaItem?> createPrincipal(Map<String, dynamic> payload) async {
    _isSaving  = true;
    _saveError = null;
    notifyListeners();
    try {
      final item = await _repo.createPrincipal(payload);
      await loadPage();
      return item;
    } on ApiException catch (e) {
      _saveError = e.message;
      return null;
    } catch (_) {
      _saveError = 'Error de conexión.';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<CompetenciaItem?> createTransversal(Map<String, dynamic> payload) async {
    _isSaving  = true;
    _saveError = null;
    notifyListeners();
    try {
      final item = await _repo.createTransversal(payload);
      await loadPage();
      return item;
    } on ApiException catch (e) {
      _saveError = e.message;
      return null;
    } catch (_) {
      _saveError = 'Error de conexión.';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<CompetenciaItem?> update(int id, Map<String, dynamic> payload) async {
    _isSaving  = true;
    _saveError = null;
    notifyListeners();
    try {
      final item = await _repo.update(id, payload);
      _detail = item;
      await loadPage(page: _page);
      return item;
    } on ApiException catch (e) {
      _saveError = e.message;
      return null;
    } catch (_) {
      _saveError = 'Error de conexión.';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> delete(int id) async {
    _isDeleting = true;
    notifyListeners();
    try {
      await _repo.delete(id);
      _items.removeWhere((e) => e.id == id);
      _total = (_total - 1).clamp(0, 9999);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Error de conexión al eliminar.';
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  void clearSaveError() {
    _saveError = null;
    notifyListeners();
  }

  // ── Listado completo para selects (ej: "Nuevo RAP") ─────────────────────
  // Independiente de la paginación del listado principal: trae todas las
  // competencias de una sola vez para poblar un dropdown.
  List<CompetenciaItem> _dropdownItems = [];
  bool                  _isLoadingDropdown = false;
  String?               dropdownError;

  List<CompetenciaItem> get dropdownItems     => _dropdownItems;
  bool                   get isLoadingDropdown => _isLoadingDropdown;

  Future<void> fetchCompetenciasForDropdown({bool force = false}) async {
    if (_isLoadingDropdown) return;
    if (_dropdownItems.isNotEmpty && !force) return;
    _isLoadingDropdown = true;
    dropdownError = null;
    notifyListeners();
    try {
      final res = await _repo.list(page: 1, pageSize: 500);
      _dropdownItems = res.results;
    } on ApiException catch (e) {
      dropdownError = e.message;
    } catch (_) {
      dropdownError = 'Error de conexión.';
    } finally {
      _isLoadingDropdown = false;
      notifyListeners();
    }
  }
}
