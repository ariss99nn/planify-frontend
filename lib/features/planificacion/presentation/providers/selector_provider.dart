// lib/features/planificacion/presentation/providers/selector_provider.dart

import 'package:flutter/foundation.dart';

import '../../data/models/selector_models.dart';

typedef SelectorSearchFn<T extends Seleccionable> = Future<List<T>> Function(
  String? query,
);

class SelectorProvider<T extends Seleccionable> extends ChangeNotifier {
  final SelectorSearchFn<T> _searchFn;

  /// Caché simple por query — evita refetch al reabrir el mismo sheet
  /// con el mismo texto de búsqueda dentro de la misma sesión.
  final Map<String, List<T>> _cache = {};

  SelectorProvider(this._searchFn);

  List<T> _resultados = [];
  bool    _isLoading  = false;
  String? _error;

  List<T> get resultados => _resultados;
  bool    get isLoading  => _isLoading;
  String? get error      => _error;

  Future<void> buscar(String? query) async {
    final key = query?.trim() ?? '';

    if (_cache.containsKey(key)) {
      _resultados = _cache[key]!;
      _error      = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error     = null;
    notifyListeners();

    try {
      final res   = await _searchFn(key.isEmpty ? null : key);
      _cache[key] = res;
      _resultados = res;
    } catch (_) {
      _error      = 'No se pudo cargar la lista. Intenta de nuevo.';
      _resultados = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void invalidarCache() => _cache.clear();
}
