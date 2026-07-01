// lib/features/ficha/data/datasources/ficha_remote_datasource.dart

import '../../../../core/api/api_service.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/ficha_model.dart';

class FichaRemoteDatasource {
  static Future<String?> _token() => TokenStorage.getAccessToken();

  // ── Fichas ─────────────────────────────────────────────────────────────────

  Future<PaginatedResponse<FichaListModel>> getFichas({
    String? search,
    String? etapa,
    String? jornada,
    String? estado,
    bool? cadenaFormacion,
    int? programa,
    int? version,
    int? jefeGrupo,
    int page     = 1,
    int pageSize = 20,
  }) async {
    final params = <String, String>{
      'page':      page.toString(),
      'page_size': pageSize.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (etapa != null)           'etapa':            etapa,
      if (jornada != null)         'jornada':          jornada,
      if (estado != null)          'estado':           estado,
      if (cadenaFormacion != null) 'cadena_formacion': cadenaFormacion.toString(),
      if (programa != null)        'programa':         programa.toString(),
      if (version != null)         'version':          version.toString(),
      if (jefeGrupo != null)       'jefe_grupo':       jefeGrupo.toString(),
    };
    final data = await ApiService.get(
      '/fichas/',
      token: await _token(),
      queryParams: params,
    ) as Map<String, dynamic>;
    return PaginatedResponse.fromJson(data, FichaListModel.fromJson);
  }

  Future<FichaModel> getFicha(int id) async {
    final data = await ApiService.get(
      '/fichas/$id/',
      token: await _token(),
    ) as Map<String, dynamic>;
    return FichaModel.fromJson(data);
  }

  Future<FichaModel> createFicha(Map<String, dynamic> body) async {
    final data = await ApiService.post(
      '/fichas/create/',
      token: await _token(),
      data: body,
    ) as Map<String, dynamic>;
    return FichaModel.fromJson(data);
  }

  Future<FichaModel> updateFicha(int id, Map<String, dynamic> body) async {
    final data = await ApiService.patch(
      '/fichas/$id/update/',
      token: await _token(),
      data: body,
    ) as Map<String, dynamic>;
    return FichaModel.fromJson(data);
  }

  Future<FichaModel> updateEtapa(
    int id, {
    required String etapa,
    required int trimestre,
  }) async {
    final data = await ApiService.patch(
      '/fichas/$id/etapa/',
      token: await _token(),
      data: {'etapa': etapa, 'trimestre': trimestre},
    ) as Map<String, dynamic>;
    return FichaModel.fromJson(data);
  }

  // ── Estudiantes ────────────────────────────────────────────────────────────

  Future<PaginatedResponse<FichaEstudianteModel>> getEstudiantes(
    int fichaId, {
    bool? activo,
    bool? esCadena,
    String? motivoRetiro,
    int page     = 1,
    int pageSize = 20,
  }) async {
    final params = <String, String>{
      'page':      page.toString(),
      'page_size': pageSize.toString(),
      if (activo != null)       'activo':        activo.toString(),
      if (esCadena != null)     'es_cadena':     esCadena.toString(),
      if (motivoRetiro != null) 'motivo_retiro': motivoRetiro,
    };
    final data = await ApiService.get(
      '/fichas/$fichaId/estudiantes/',
      token: await _token(),
      queryParams: params,
    ) as Map<String, dynamic>;
    return PaginatedResponse.fromJson(data, FichaEstudianteModel.fromJson);
  }

  Future<FichaEstudianteModel> addEstudiante(
    int fichaId, {
    required int estudianteId,
    required bool esCadena,
  }) async {
    final data = await ApiService.post(
      '/fichas/$fichaId/estudiantes/add/',
      token: await _token(),
      data: {'ficha': fichaId, 'estudiante': estudianteId, 'es_cadena': esCadena},
    ) as Map<String, dynamic>;
    return FichaEstudianteModel.fromJson(data);
  }

  Future<FichaEstudianteModel> updateEstudiante(
    int fichaId,
    int relacionId,
    Map<String, dynamic> body,
  ) async {
    final data = await ApiService.patch(
      '/fichas/$fichaId/estudiantes/$relacionId/',
      token: await _token(),
      data: body,
    ) as Map<String, dynamic>;
    return FichaEstudianteModel.fromJson(data);
  }

  // ── Reasignaciones ─────────────────────────────────────────────────────────

  Future<PaginatedResponse<ReasignacionModel>> getReasignaciones({
    int? estudianteId,
    int? fichaOrigenId,
    int? fichaDestinoId,
    int page     = 1,
    int pageSize = 20,
  }) async {
    final params = <String, String>{
      'page':      page.toString(),
      'page_size': pageSize.toString(),
      if (estudianteId != null)   'estudiante':    estudianteId.toString(),
      if (fichaOrigenId != null)  'ficha_origen':  fichaOrigenId.toString(),
      if (fichaDestinoId != null) 'ficha_destino': fichaDestinoId.toString(),
    };
    final data = await ApiService.get(
      '/fichas/reasignaciones/',
      token: await _token(),
      queryParams: params,
    ) as Map<String, dynamic>;
    return PaginatedResponse.fromJson(data, ReasignacionModel.fromJson);
  }

  Future<ReasignacionModel> createReasignacion(Map<String, dynamic> body) async {
    final data = await ApiService.post(
      '/fichas/reasignaciones/create/',
      token: await _token(),
      data: body,
    ) as Map<String, dynamic>;
    return ReasignacionModel.fromJson(data);
  }

  // ── Historial ──────────────────────────────────────────────────────────────

  Future<PaginatedResponse<HistorialEtapaModel>> getHistorial({
    int? fichaId,
    String? etapaNueva,
    String? etapaAnterior,
    int page     = 1,
    int pageSize = 20,
  }) async {
    final params = <String, String>{
      'page':      page.toString(),
      'page_size': pageSize.toString(),
      if (fichaId != null)       'ficha':          fichaId.toString(),
      if (etapaNueva != null)    'etapa_nueva':    etapaNueva,
      if (etapaAnterior != null) 'etapa_anterior': etapaAnterior,
    };
    final data = await ApiService.get(
      '/fichas/historial/',
      token: await _token(),
      queryParams: params,
    ) as Map<String, dynamic>;
    return PaginatedResponse.fromJson(data, HistorialEtapaModel.fromJson);
  }
}
