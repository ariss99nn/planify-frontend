import 'package:flutter/foundation.dart';

import '../../data/models/asignatura_model.dart';
import '../../data/repositories_impl/asignatura_repository_impl.dart';
import '../../domain/repositories/asignatura_repository.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/api/api_service.dart';

class AsignaturaProvider extends ChangeNotifier {
  AsignaturaProvider({AsignaturaRepository? repo})
      : _repo = repo ?? const AsignaturaRepositoryImpl();

  final AsignaturaRepository _repo;

  List<AsignaturaItem> _items     = [];
  bool                 _isLoading = false;
  String?              _error;
  int                  _page      = 1;
  int                  _total     = 0;
  bool                 _hasNext   = false;
  bool                 _hasPrev   = false;

  String _search = '';
  String _tipo   = '';
  String _estado = '';
  int?   _modulo;

  AsignaturaItem? _detail;
  bool            _isLoadingDetail = false;
  String?         _detailError;

  bool    _isSaving   = false;
  bool    _isDeleting = false;
  String? _saveError;

  List<AsignaturaItem> get items           => _items;
  bool                 get isLoading       => _isLoading;
  String?              get error           => _error;
  int                  get currentPage     => _page;
  int                  get totalCount      => _total;
  bool                 get hasNext         => _hasNext;
  bool                 get hasPrevious     => _hasPrev;
  String               get search          => _search;
  String               get tipo            => _tipo;
  String               get estado          => _estado;
  int?                 get modulo          => _modulo;
  AsignaturaItem?      get detail          => _detail;
  bool                 get isLoadingDetail => _isLoadingDetail;
  String?              get detailError     => _detailError;
  bool                 get isSaving        => _isSaving;
  bool                 get isDeleting      => _isDeleting;
  String?              get saveError       => _saveError;

  Future<void> loadPage({int page = 1}) async {
    _isLoading = true;
    _error     = null;
    _page      = page;
    notifyListeners();

    try {
      final PaginatedResponse<AsignaturaItem> res = await _repo.list(
        search:   _search,
        tipo:     _tipo,
        estado:   _estado,
        modulo:   _modulo,
        page:     page,
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

  void setSearch(String v) { _search = v; loadPage(); }
  void setTipo(String v)   { _tipo   = v; loadPage(); }
  void setEstado(String v) { _estado = v; loadPage(); }
  void setModulo(int? v)   { _modulo = v; loadPage(); }

  void clearFilters() {
    _search = '';
    _tipo   = '';
    _estado = '';
    _modulo = null;
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

  Future<AsignaturaItem?> create(Map<String, dynamic> payload) async {
    _isSaving  = true;
    _saveError = null;
    notifyListeners();
    try {
      final item = await _repo.create(payload);
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

  Future<AsignaturaItem?> update(int id, Map<String, dynamic> payload) async {
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
}
