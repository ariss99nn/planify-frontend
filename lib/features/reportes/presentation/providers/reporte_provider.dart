import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/api/api_service.dart';
import '../../data/repositories_impl/reporte_repository_impl.dart';
import '../../domain/entities/reporte_generado_entity.dart';
import '../../domain/repositories/reporte_repository.dart';
import '../../domain/usecases/reporte_usecases.dart';

class ReporteProvider extends ChangeNotifier {
  ReporteProvider({ReporteRepository? repository}) {
    final repo = repository ?? ReporteRepositoryImpl();
    _solicitar = SolicitarReporteUseCase(repo);
    _obtenerEstado = ObtenerEstadoReporteUseCase(repo);
  }

  late final SolicitarReporteUseCase _solicitar;
  late final ObtenerEstadoReporteUseCase _obtenerEstado;

  static const Duration _intervaloPolling = Duration(seconds: 3);
  static const int _maxIntentosPolling = 40;

  final List<ReporteGeneradoEntity> _historial = [];
  List<ReporteGeneradoEntity> get historial => List.unmodifiable(_historial);

  bool _solicitando = false;
  bool get solicitando => _solicitando;

  String? _errorSolicitud;
  String? get errorSolicitud => _errorSolicitud;

  ReporteGeneradoEntity? _reporteActivo;
  ReporteGeneradoEntity? get reporteActivo => _reporteActivo;

  bool _consultandoEstado = false;
  bool get consultandoEstado => _consultandoEstado;

  String? _errorEstado;
  String? get errorEstado => _errorEstado;

  bool _seguimientoAgotado = false;
  bool get seguimientoAgotado => _seguimientoAgotado;

  Timer? _pollingTimer;
  int _intentosPolling = 0;

  Future<ReporteGeneradoEntity?> solicitar({
    required ReporteTipo tipo,
    Map<String, dynamic> filtros = const {},
  }) async {
    _solicitando = true;
    _errorSolicitud = null;
    notifyListeners();

    try {
      final reporte = await _solicitar(tipo: tipo, filtros: filtros);
      _historial.insert(0, reporte);
      _iniciarSeguimiento(reporte);
      return reporte;
    } on ApiException catch (e) {
      _errorSolicitud = e.message;
      return null;
    } catch (_) {
      _errorSolicitud = 'No se pudo solicitar el reporte.';
      return null;
    } finally {
      _solicitando = false;
      notifyListeners();
    }
  }

  void _iniciarSeguimiento(ReporteGeneradoEntity reporte) {
    _pollingTimer?.cancel();
    _reporteActivo = reporte;
    _errorEstado = null;
    _seguimientoAgotado = false;
    _intentosPolling = 0;

    if (reporte.estado.esFinal) return;

    _pollingTimer = Timer.periodic(_intervaloPolling, (_) {
      _consultarEstado(reporte.id);
    });
  }

  Future<void> consultarReporte(int id) async {
    _consultandoEstado = true;
    _errorEstado = null;
    notifyListeners();

    try {
      final reporte = await _obtenerEstado(id);
      _reporteActivo = reporte;
      _actualizarHistorial(reporte);

      _pollingTimer?.cancel();
      _pollingTimer = null;
      _intentosPolling = 0;
      _seguimientoAgotado = false;

      if (!reporte.estado.esFinal) {
        _pollingTimer = Timer.periodic(_intervaloPolling, (_) {
          _consultarEstado(reporte.id);
        });
      }
    } on ApiException catch (e) {
      _errorEstado = e.message;
    } catch (_) {
      _errorEstado = 'No se pudo consultar el estado del reporte.';
    } finally {
      _consultandoEstado = false;
      notifyListeners();
    }
  }

  Future<void> _consultarEstado(int id) async {
    _intentosPolling += 1;
    try {
      final reporte = await _obtenerEstado(id);
      _reporteActivo = reporte;
      _actualizarHistorial(reporte);

      if (reporte.estado.esFinal) {
        _pollingTimer?.cancel();
        _pollingTimer = null;
      } else if (_intentosPolling >= _maxIntentosPolling) {
        _pollingTimer?.cancel();
        _pollingTimer = null;
        _seguimientoAgotado = true;
      }
      notifyListeners();
    } on ApiException catch (e) {
      _errorEstado = e.message;
      _pollingTimer?.cancel();
      _pollingTimer = null;
      notifyListeners();
    } catch (_) {
      // Error transitorio de red: se reintenta en el siguiente tick.
    }
  }

  void _actualizarHistorial(ReporteGeneradoEntity reporte) {
    final index = _historial.indexWhere((r) => r.id == reporte.id);
    if (index != -1) {
      _historial[index] = reporte;
    }
  }

  void detenerSeguimiento() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
