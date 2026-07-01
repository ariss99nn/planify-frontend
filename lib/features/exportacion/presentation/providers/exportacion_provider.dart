import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../core/api/api_service.dart';
import '../../data/repositories_impl/exportacion_repository_impl.dart';
import '../../domain/entities/exportacion_enums.dart';
import '../../domain/entities/registro_exportacion_entity.dart';
import '../../domain/usecases/exportar_datos_usecase.dart';
import '../../domain/usecases/obtener_log_exportacion_usecase.dart';

enum ExportStatus { idle, loading, success, error }
enum LogStatus    { idle, loading, success, error }

class ExportacionProvider extends ChangeNotifier {
  ExportacionProvider({
    ExportarDatosUseCase?         exportarUseCase,
    ObtenerLogExportacionUseCase? logUseCase,
  }) {
    final repo       = ExportacionRepositoryImpl();
    _exportarUseCase = exportarUseCase  ?? ExportarDatosUseCase(repo);
    _logUseCase      = logUseCase       ?? ObtenerLogExportacionUseCase(repo);
  }

  late final ExportarDatosUseCase         _exportarUseCase;
  late final ObtenerLogExportacionUseCase _logUseCase;

  // ── Estado de exportación ─────────────────────────────────────────────────

  ExportStatus _exportStatus = ExportStatus.idle;
  String?      _exportError;
  File?        _lastFile;
  String?      _lastFileName;

  ExportStatus get exportStatus  => _exportStatus;
  String?      get exportError   => _exportError;
  File?        get lastFile      => _lastFile;
  String?      get lastFileName  => _lastFileName;
  bool         get isExporting   => _exportStatus == ExportStatus.loading;
  bool         get exportSuccess => _exportStatus == ExportStatus.success;
  bool         get hasExportError => _exportStatus == ExportStatus.error;

  Future<void> exportar({
    required TipoExportacion    modulo,
    required FormatoExportacion formato,
    Map<String, String> filtros = const {},
  }) async {
    if (_exportStatus == ExportStatus.loading) return;

    _lastFile     = null;
    _lastFileName = null;
    _exportError  = null;
    _setExportState(ExportStatus.loading);

    try {
      final result = await _exportarUseCase(
        modulo:  modulo,
        formato: formato,
        filtros: filtros,
      );
      _lastFile     = result.file;
      _lastFileName = result.fileName;
      _setExportState(ExportStatus.success);
    } catch (e) {
      _exportError = _clean(e);
      _setExportState(ExportStatus.error);
    }
  }

  void resetExport() {
    _lastFile     = null;
    _lastFileName = null;
    _exportError  = null;
    _setExportState(ExportStatus.idle);
  }

  // ── Estado del log ────────────────────────────────────────────────────────

  LogStatus                       _logStatus    = LogStatus.idle;
  String?                         _logError;
  List<RegistroExportacionEntity> _logs         = [];
  int                             _logTotal     = 0;
  int                             _logPage      = 1;
  TipoExportacion?                _filtroTipo;
  bool                            _logLoaded    = false;
  int                             _logRequestId = 0;

  static const int pageSize = 20;

  LogStatus                       get logStatus    => _logStatus;
  String?                         get logError     => _logError;
  List<RegistroExportacionEntity> get logs         => List.unmodifiable(_logs);
  int                             get logTotal     => _logTotal;
  int                             get logPage      => _logPage;
  TipoExportacion?                get filtroTipo   => _filtroTipo;
  bool                            get logLoaded    => _logLoaded;
  bool                            get isLoadingLog => _logStatus == LogStatus.loading;
  int get totalPages =>
      _logTotal == 0 ? 1 : (_logTotal / pageSize).ceil();

  Future<void> cargarLog({bool reiniciar = false}) async {
    if (reiniciar) {
      _logPage   = 1;
      _logLoaded = false;
      _logs      = [];
    }

    final requestId = ++_logRequestId;
    _logStatus = LogStatus.loading;
    _logError  = null;
    notifyListeners();

    try {
      final page = await _logUseCase(
        page:     _logPage,
        pageSize: pageSize,
        tipo:     _filtroTipo,
      );
      if (requestId != _logRequestId) return;

      _logs      = page.results;
      _logTotal  = page.count;
      _logLoaded = true;
      _logStatus = LogStatus.success;
    } catch (e) {
      if (requestId != _logRequestId) return;
      _logError  = _clean(e);
      _logStatus = LogStatus.error;
    }

    notifyListeners();
  }

  void irAPagina(int page) {
    assert(page >= 1 && page <= totalPages);
    if (page == _logPage) return;
    _logPage = page;
    cargarLog();
  }

  void paginaSiguiente() {
    if (_logPage < totalPages) irAPagina(_logPage + 1);
  }

  void paginaAnterior() {
    if (_logPage > 1) irAPagina(_logPage - 1);
  }

  void setFiltroTipo(TipoExportacion? tipo) {
    if (tipo == _filtroTipo) return;
    _filtroTipo = tipo;
    cargarLog(reiniciar: true);
  }

  void limpiarFiltros() => setFiltroTipo(null);

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _setExportState(ExportStatus status) {
    _exportStatus = status;
    notifyListeners();
  }

  String _clean(Object e) {
    if (e is ApiException) return e.message;
    return e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  }
}
