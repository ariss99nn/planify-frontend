import 'package:flutter/foundation.dart';

import '../../domain/entities/auditoria_entity.dart';
import '../../domain/usecases/auditoria_usecases.dart';

class AuditoriaProvider extends ChangeNotifier {
  final GetAuditLogUseCase _getAuditLog;
  AuditoriaProvider({required GetAuditLogUseCase getAuditLog})
      : _getAuditLog = getAuditLog;

  List<AuditLogEntity> registros = [];
  bool loading = false;
  bool loadingMore = false;
  String? error;
  int _page = 1;
  bool _hasNext = true;
  int total = 0;

  String? filtroMetodo;
  String? filtroPath;

  Future<void> cargar({bool reset = true}) async {
    if (reset) {
      _page = 1;
      registros = [];
      _hasNext = true;
    }
    loading = true;
    error = null;
    notifyListeners();
    try {
      final pagina = await _getAuditLog(
        page: _page,
        metodo: filtroMetodo,
        path: filtroPath,
      );
      registros = pagina.items;
      total = pagina.total;
      _hasNext = pagina.hasNext;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> cargarMas() async {
    if (!_hasNext || loadingMore) return;
    loadingMore = true;
    notifyListeners();
    try {
      _page += 1;
      final pagina = await _getAuditLog(
        page: _page,
        metodo: filtroMetodo,
        path: filtroPath,
      );
      registros = [...registros, ...pagina.items];
      _hasNext = pagina.hasNext;
    } catch (e) {
      error = e.toString();
      _page -= 1;
    } finally {
      loadingMore = false;
      notifyListeners();
    }
  }

  void aplicarFiltros({String? metodo, String? path}) {
    filtroMetodo = metodo;
    filtroPath = path;
    cargar(reset: true);
  }
}
