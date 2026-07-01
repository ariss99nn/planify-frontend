// lib/features/bhorario/data/repositories/horario_repository.dart

import '../../../../core/api/api_service.dart';
import '../models/bloque_horario_model.dart';

class HorarioRepository {
  static const String _base = '/horarios';

  /// GET /horarios/semanal/
  static Future<HorarioSemanalResponse> getHorarioSemanal({
    required String token,
    String? docenteId,
    String? aulaId,
    String? fichaId,
    String? jornada,
  }) async {
    final params = <String, String>{};
    if (docenteId != null) params['docente'] = docenteId;
    if (aulaId    != null) params['aula']     = aulaId;
    if (fichaId   != null) params['ficha']    = fichaId;
    if (jornada   != null) params['jornada']  = jornada;

    final raw = await ApiService.get(
      '$_base/semanal/',
      token: token,
      queryParams: params.isNotEmpty ? params : null,
    );
    return HorarioSemanalResponse.fromJson(raw as Map<String, dynamic>);
  }

  /// GET /horarios/<pk>/
  static Future<BloqueHorarioModel> getBloque({
    required String token,
    required int id,
  }) async {
    final raw = await ApiService.get('$_base/$id/', token: token);
    return BloqueHorarioModel.fromJson(raw as Map<String, dynamic>);
  }

  /// POST /horarios/create/
  static Future<BloqueHorarioModel> createBloque({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final raw = await ApiService.post('$_base/create/', token: token, data: data);
    return BloqueHorarioModel.fromJson(raw as Map<String, dynamic>);
  }

  /// PATCH /horarios/<pk>/update/
  static Future<BloqueHorarioModel> updateBloque({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final raw = await ApiService.patch('$_base/$id/update/', token: token, data: data);
    return BloqueHorarioModel.fromJson(raw as Map<String, dynamic>);
  }

  /// DELETE /horarios/<pk>/delete/
  static Future<void> deleteBloque({
    required String token,
    required int id,
  }) async {
    await ApiService.delete('$_base/$id/delete/', token: token);
  }

  /// POST /horarios/disponibilidad/
  static Future<Map<String, dynamic>> verificarDisponibilidad({
    required String token,
    required String diaSemana,
    required String horaInicio,
    required String horaFin,
    int? docenteId,
    int? aulaId,
    int? fichaId,
    int? excluirPk,
  }) async {
    final raw = await ApiService.post(
      '$_base/disponibilidad/',
      token: token,
      data: {
        'dia_semana':  diaSemana,
        'hora_inicio': horaInicio,
        'hora_fin':    horaFin,
        if (docenteId != null) 'docente':    docenteId,
        if (aulaId    != null) 'aula':       aulaId,
        if (fichaId   != null) 'ficha':      fichaId,
        if (excluirPk != null) 'excluir_pk': excluirPk,
      },
    );
    return raw as Map<String, dynamic>;
  }
}