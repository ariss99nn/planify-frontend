// lib/features/planificacion/presentation/providers/selector_provider.dart

import 'package:flutter/foundation.dart';

import '../../../../core/api/api_service.dart';
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

  /// Última búsqueda intentada, para poder reintentar exactamente lo mismo
  /// desde el botón "Reintentar" sin que el usuario tenga que volver a
  /// escribir el texto de búsqueda.
  String? _ultimaQuery;

  List<T> get resultados => _resultados;
  bool    get isLoading  => _isLoading;
  String? get error      => _error;

  Future<void> buscar(String? query) async {
    final key = query?.trim() ?? '';
    _ultimaQuery = key;

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
    } on ApiException catch (e) {
      // Mensaje real del backend (p. ej. sesión expirada, validación,
      // servicio caído) en vez de un texto genérico que oculta la causa.
      _error = e.statusCode >= 500
          ? 'El servidor no pudo procesar la búsqueda (${e.statusCode}). '
              'Intenta de nuevo en unos segundos.'
          : e.message;
      _resultados = [];
    } catch (_) {
      // Sin conexión, timeout u otro error de red que no vino del backend.
      _error = 'No se pudo conectar con el servidor. Verifica tu conexión '
          'e intenta de nuevo.';
      _resultados = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reintenta la última búsqueda (misma query) sin pasar por caché, útil
  /// tras un error transitorio del servidor.
  Future<void> reintentar() => buscar(_ultimaQuery);

  void invalidarCache() => _cache.clear();
}
