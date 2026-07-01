import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/alerta_entity.dart';
import '../../domain/repositories/alerta_repository.dart';
import '../../domain/usecases/listar_alertas_usecase.dart';
import '../../domain/usecases/marcar_alerta_leida_usecase.dart';

enum AlertasStatus { initial, loading, loadingMore, loaded, error }

class AlertasProvider extends ChangeNotifier {
  final ListarAlertasUseCase _listar;
  final MarcarAlertaLeidaUseCase _marcarLeida;

  AlertasProvider({
    required ListarAlertasUseCase listar,
    required MarcarAlertaLeidaUseCase marcarLeida,
  })  : _listar = listar,
        _marcarLeida = marcarLeida;

  // ── Estado ───────────────────────────────────────────────────────────────

  AlertasStatus _status = AlertasStatus.initial;
  AlertasStatus get status => _status;

  List<AlertaEntity> _alertas = [];
  List<AlertaEntity> get alertas => _alertas;

  List<AlertaEntity> _alertasHoy = [];
  List<AlertaEntity> get alertasHoy => _alertasHoy;

  List<AlertaEntity> _alertasAnteriores = [];
  List<AlertaEntity> get alertasAnteriores => _alertasAnteriores;

  int get noLeidas => _alertas.where((a) => !a.isLeida).length;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _errorPaginacion = false;
  bool get errorPaginacion => _errorPaginacion;

  int _page = 1;
  static const _pageSize = 20;

  // ── Filtros ───────────────────────────────────────────────────────────────

  String? _filtroEstado;
  String? get filtroEstado => _filtroEstado;

  String? _filtroTipo;
  String? get filtroTipo => _filtroTipo;

  /// Aplica ambos filtros en una sola operación y relanza la carga.
  /// Evita la double-request del diseño anterior con dos callbacks separados.
  void aplicarFiltros({String? estado, String? tipo}) {
    if (_filtroEstado == estado && _filtroTipo == tipo) return;
    _filtroEstado = estado;
    _filtroTipo = tipo;
    cargar();
  }

  // ── Carga inicial / refresh ───────────────────────────────────────────────

  Future<void> cargar() async {
    _status = AlertasStatus.loading;
    _errorMessage = null;
    _page = 1;
    _hasMore = true;
    _errorPaginacion = false;
    notifyListeners();

    final result = await _listar(
      AlertaFiltros(
        estado: _filtroEstado,
        tipo: _filtroTipo,
        page: _page,
        pageSize: _pageSize,
      ),
    );

    result.fold(
      (failure) {
        _status = AlertasStatus.error;
        _errorMessage = _mensajeDeError(failure);
      },
      (page) {
        _alertas = page.items;
        _hasMore = page.hasMore;
        _status = AlertasStatus.loaded;
        _agrupar();
      },
    );

    notifyListeners();
  }

  // ── Scroll infinito ───────────────────────────────────────────────────────

  Future<void> cargarMas() async {
    if (_status == AlertasStatus.loadingMore ||
        !_hasMore ||
        _status == AlertasStatus.loading ||
        _errorPaginacion) return;

    _status = AlertasStatus.loadingMore;
    notifyListeners();

    final result = await _listar(
      AlertaFiltros(
        estado: _filtroEstado,
        tipo: _filtroTipo,
        page: _page + 1,
        pageSize: _pageSize,
      ),
    );

    result.fold(
      (failure) {
        _status = AlertasStatus.loaded; // volvemos a loaded, no a error global
        _errorPaginacion = true;
      },
      (page) {
        _page++;
        _alertas = [..._alertas, ...page.items];
        _hasMore = page.hasMore;
        _status = AlertasStatus.loaded;
        _agrupar();
      },
    );

    notifyListeners();
  }

  // ── Marcar leída ──────────────────────────────────────────────────────────

  Future<String?> marcarLeida(AlertaEntity alerta, int currentUserId) async {
    final result = await _marcarLeida(
      alerta: alerta,
      currentUserId: currentUserId,
    );

    return result.fold(
      (failure) => _mensajeDeError(failure),
      (updated) {
        final idx = _alertas.indexWhere((a) => a.id == updated.id);
        if (idx != -1) {
          _alertas = List.of(_alertas)..[idx] = updated;
          _agrupar();
          notifyListeners();
        }
        return null; // null = éxito
      },
    );
  }

  // ── Agrupación memoizada ──────────────────────────────────────────────────
  // Se calcula una sola vez al recibir datos, no en cada build.

  void _agrupar() {
    final soloHoy = DateUtils.dateOnly(DateTime.now());
    _alertasHoy = _alertas
        .where((a) => DateUtils.dateOnly(a.fechaCreacion) == soloHoy)
        .toList();
    _alertasAnteriores = _alertas
        .where((a) => DateUtils.dateOnly(a.fechaCreacion) != soloHoy)
        .toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _mensajeDeError(Failure failure) => switch (failure) {
        NetworkFailure() => 'Sin conexión a Internet.',
        AuthorizationFailure() => failure.message,
        ServerFailure() => 'Error del servidor. Intenta de nuevo.',
        _ => 'Ocurrió un error inesperado.',
      };
}
