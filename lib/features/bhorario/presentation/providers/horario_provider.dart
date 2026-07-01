// lib/features/bhorario/presentation/providers/horario_provider.dart

import 'package:flutter/foundation.dart';
import '../../../../core/api/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/models/bloque_horario_model.dart';
import '../../data/repositories/horario_repository.dart';

enum HorarioStatus { idle, loading, success, error }

class HorarioProvider extends ChangeNotifier {
  // ── Estado ─────────────────────────────────────────────────────────────────
  HorarioStatus _status  = HorarioStatus.idle;
  String?        _error;
  HorarioSemanalResponse? _horarioSemanal;
  String  _diaSeleccionado = 'LUNES';
  String? _filtroJornada;

  // ── Getters públicos ────────────────────────────────────────────────────────
  HorarioStatus           get status          => _status;
  String?                 get error           => _error;
  HorarioSemanalResponse? get horarioSemanal  => _horarioSemanal;
  String                  get diaSeleccionado => _diaSeleccionado;
  String?                 get filtroJornada   => _filtroJornada;

  bool get isLoading => _status == HorarioStatus.loading;
  bool get hasError  => _status == HorarioStatus.error;
  bool get hasData   => _status == HorarioStatus.success;

  List<BloqueHorarioModel> get bloquesDiaActual =>
      _horarioSemanal?.dias[_diaSeleccionado]?.bloques ?? [];

  // ── Mutaciones de UI (sin red) ──────────────────────────────────────────────
  void seleccionarDia(String dia) {
    if (_diaSeleccionado == dia) return;
    _diaSeleccionado = dia;
    notifyListeners();
  }

  void setFiltroJornada(String? jornada) {
    if (_filtroJornada == jornada) return;
    _filtroJornada = jornada;
    notifyListeners();
    loadHorarioSemanal();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Operaciones de red ──────────────────────────────────────────────────────

  Future<void> loadHorarioSemanal({
    String? docenteId,
    String? fichaId,
  }) async {
    _setLoading();
    try {
      final token = await _requireToken();
      _horarioSemanal = await HorarioRepository.getHorarioSemanal(
        token:     token,
        docenteId: docenteId,
        fichaId:   fichaId,
        jornada:   _filtroJornada,
      );
      // Auto-selecciona el primer día con bloques si el actual está vacío
      if (bloquesDiaActual.isEmpty && _horarioSemanal!.dias.isNotEmpty) {
        _diaSeleccionado = _horarioSemanal!.dias.keys.first;
      }
      _setSuccess();
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Error inesperado: $e');
    }
  }

  Future<BloqueHorarioModel?> createBloque(Map<String, dynamic> data) async {
    try {
      final token  = await _requireToken();
      final bloque = await HorarioRepository.createBloque(token: token, data: data);
      await loadHorarioSemanal();
      return bloque;
    } on ApiException catch (e) {
      _setError(e.message);
      return null;
    }
  }

  Future<BloqueHorarioModel?> updateBloque(
      int id, Map<String, dynamic> data) async {
    try {
      final token  = await _requireToken();
      final bloque = await HorarioRepository.updateBloque(
          token: token, id: id, data: data);
      await loadHorarioSemanal();
      return bloque;
    } on ApiException catch (e) {
      _setError(e.message);
      return null;
    }
  }

  Future<bool> deleteBloque(int id) async {
    try {
      final token = await _requireToken();
      await HorarioRepository.deleteBloque(token: token, id: id);
      await loadHorarioSemanal();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // ── Helpers privados ────────────────────────────────────────────────────────

  Future<String> _requireToken() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw ApiException(message: 'Sesión expirada', statusCode: 401);
    return token;
  }

  void _setLoading() {
    _status = HorarioStatus.loading;
    _error  = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = HorarioStatus.success;
    _error  = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status = HorarioStatus.error;
    _error  = msg;
    notifyListeners();
  }
}