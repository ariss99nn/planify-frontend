// lib/features/docentes/data/datasources/docente_remote_datasource.dart

import 'package:image_picker/image_picker.dart';
import '../../../../core/api/api_service.dart';
import '../../../../core/storage/token_storage.dart';

class DocenteRemoteDatasource {
  static Future<dynamic> getDocentes({
    String? search,
    bool?   estado,
    String? especialidad,
    int     page = 1,
  }) async {
    final token  = await TokenStorage.getAccessToken();
    final params = <String, String>{
      if (search       != null && search.isNotEmpty)       'search':       search,
      if (especialidad != null && especialidad.isNotEmpty) 'especialidad': especialidad,
      if (estado       != null) 'estado': estado ? 'true' : 'false',
      'page': '$page',
    };
    return ApiService.get('/docentes/', token: token, queryParams: params);
  }

  static Future<dynamic> getDocente(int id) async {
    final token = await TokenStorage.getAccessToken();
    return ApiService.get('/docentes/$id/', token: token);
  }

  static Future<dynamic> createDocente({
    required int    userId,
    required String especialidad,
    required int    horasMaxSemanales,
    bool            estado                = true,
    bool            permiteHorasExtra     = false,
    int             horasExtraAutorizadas = 0,
    XFile?          imagen,
  }) async {
    final token = await TokenStorage.getAccessToken();
    return ApiService.postMultipart(
      '/docentes/create/',
      token: token,
      fields: {
        'user_id':                 '$userId',
        'especialidad':            especialidad.trim(),
        'horas_max_semanales':     '$horasMaxSemanales',
        'estado':                  '$estado',
        'permite_horas_extra':     '$permiteHorasExtra',
        'horas_extra_autorizadas': '$horasExtraAutorizadas',
      },
      xfile:      imagen,
      xfileField: imagen != null ? 'imagen' : null,
    );
  }

  static Future<dynamic> updateDocente({
    required int                  id,
    required Map<String, dynamic> data,
    XFile?                        imagen,
    bool                          eliminarImagen = false,
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (imagen != null || eliminarImagen) {
      final fields = data.map((k, v) => MapEntry(k, v.toString()));
      if (eliminarImagen && imagen == null) fields['imagen'] = '';
      return ApiService.patchMultipart(
        '/docentes/$id/update/',
        token:      token,
        fields:     fields,
        xfile:      imagen,
        xfileField: imagen != null ? 'imagen' : null,
      );
    }
    return ApiService.patch('/docentes/$id/update/', token: token, data: data);
  }

  static Future<void> deactivateDocente(int id) async {
    final token = await TokenStorage.getAccessToken();
    await ApiService.patch(
      '/docentes/$id/deactivate/',
      token: token,
      data:  {'confirmacion': true},
    );
  }

  // ── Disponibilidad ────────────────────────────────────────────────────────

  static Future<dynamic> getDisponibilidad(int docenteId) async {
    final token = await TokenStorage.getAccessToken();
    return ApiService.get('/docentes/$docenteId/disponibilidad/', token: token);
  }

  static Future<dynamic> createDisponibilidad({
    required int    docenteId,
    required String diaSemana,
    required String horaInicio,
    required String horaFin,
    bool            disponible             = true,
    String          motivo                 = '',
    String          tipoRestriccion        = 'PERMANENTE',
    String?         fechaInicioRestriccion,
    String?         fechaFinRestriccion,
  }) async {
    final token = await TokenStorage.getAccessToken();
    return ApiService.post(
      '/docentes/$docenteId/disponibilidad/',
      token: token,
      data:  {
        'docente':     docenteId,
        'dia_semana':  diaSemana,
        'hora_inicio': horaInicio,
        'hora_fin':    horaFin,
        'disponible':  disponible,
        if (!disponible && motivo.isNotEmpty) 'motivo': motivo,
        'tipo_restriccion': tipoRestriccion,
        if (tipoRestriccion == 'TEMPORAL' && fechaInicioRestriccion != null)
          'fecha_inicio_restriccion': fechaInicioRestriccion,
        if (tipoRestriccion == 'TEMPORAL' && fechaFinRestriccion != null)
          'fecha_fin_restriccion': fechaFinRestriccion,
      },
    );
  }

  static Future<dynamic> updateDisponibilidad({
    required int    docenteId,
    required int    disponibilidadId,
    bool?           disponible,
    String?         motivo,
    String?         tipoRestriccion,
    String?         fechaInicioRestriccion,
    String?         fechaFinRestriccion,
  }) async {
    final token = await TokenStorage.getAccessToken();
    return ApiService.patch(
      '/docentes/$docenteId/disponibilidad/$disponibilidadId/',
      token: token,
      data:  {
        if (disponible             != null) 'disponible':               disponible,
        if (motivo                 != null) 'motivo':                   motivo,
        if (tipoRestriccion        != null) 'tipo_restriccion':         tipoRestriccion,
        if (fechaInicioRestriccion != null) 'fecha_inicio_restriccion': fechaInicioRestriccion,
        if (fechaFinRestriccion    != null) 'fecha_fin_restriccion':    fechaFinRestriccion,
      },
    );
  }

  static Future<void> deleteDisponibilidad({
    required int docenteId,
    required int disponibilidadId,
  }) async {
    final token = await TokenStorage.getAccessToken();
    await ApiService.delete(
      '/docentes/$docenteId/disponibilidad/$disponibilidadId/',
      token: token,
    );
  }

  // ── Habilitaciones ────────────────────────────────────────────────────────

  static Future<dynamic> getHabilitaciones({
    int?    docenteId,
    String? nivel,
    bool?   activo,
    int     page = 1,
  }) async {
    final token  = await TokenStorage.getAccessToken();
    final params = <String, String>{
      if (docenteId != null) 'docente': '$docenteId',
      if (nivel     != null) 'nivel':   nivel,
      if (activo    != null) 'activo':  activo ? 'true' : 'false',
      'page': '$page',
    };
    return ApiService.get('/docentes/habilitaciones/', token: token, queryParams: params);
  }

  static Future<dynamic> createHabilitacion({
    required int    docenteId,
    required String nivel,
    int?            moduloId,
    int?            asignaturaId,
    required String fechaDesde,
    String?         fechaHasta,
    String          observaciones = '',
  }) async {
    final token = await TokenStorage.getAccessToken();
    return ApiService.post(
      '/docentes/habilitaciones/',
      token: token,
      data:  {
        'docente':     docenteId,
        'nivel':       nivel,
        if (moduloId     != null) 'modulo':     moduloId,
        if (asignaturaId != null) 'asignatura': asignaturaId,
        'fecha_desde':  fechaDesde,
        if (fechaHasta != null && fechaHasta.isNotEmpty) 'fecha_hasta': fechaHasta,
        if (observaciones.isNotEmpty) 'observaciones': observaciones,
      },
    );
  }

  static Future<dynamic> updateHabilitacion({
    required int    habilitacionId,
    bool?           activo,
    String?         fechaHasta,
    String?         observaciones,
  }) async {
    final token = await TokenStorage.getAccessToken();
    return ApiService.patch(
      '/docentes/habilitaciones/$habilitacionId/',
      token: token,
      data:  {
        if (activo        != null) 'activo':        activo,
        if (fechaHasta    != null) 'fecha_hasta':   fechaHasta,
        if (observaciones != null) 'observaciones': observaciones,
      },
    );
  }
}
