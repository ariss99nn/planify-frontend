import '../models/asignatura_model.dart';
import '../models/competencia_model.dart';
import '../models/rap_model.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/api/api_service.dart';
import '../../../../core/storage/token_storage.dart';

class CompetenciaRemoteDatasource {
  const CompetenciaRemoteDatasource();

  static const _asig  = '/competencias/asignaturas';
  static const _comp  = '/competencias/competencias';
  static const _trans = '/competencias/competencias/transversales';
  static const _rap   = '/competencias/resultados';

  static Future<String?> _token() => TokenStorage.getAccessToken();

  Future<PaginatedResponse<AsignaturaItem>> listAsignaturas({
    String? search,
    String? tipo,
    String? estado,
    int?    modulo,
    int     page     = 1,
    int     pageSize = 20,
  }) async {
    final data = await ApiService.get(
      '$_asig/',
      token: await _token(),
      queryParams: {
        'page':      '$page',
        'page_size': '$pageSize',
        if (search != null && search.isNotEmpty) 'search': search,
        if (tipo   != null && tipo.isNotEmpty)   'tipo':   tipo,
        if (estado != null && estado.isNotEmpty) 'estado': estado,
        if (modulo != null)                      'modulo': '$modulo',
      },
    ) as Map<String, dynamic>;
    return PaginatedResponse.fromJson(data, AsignaturaItem.fromListJson);
  }

  Future<AsignaturaItem> getAsignatura(int id) async {
    final data = await ApiService.get('$_asig/$id/', token: await _token())
        as Map<String, dynamic>;
    return AsignaturaItem.fromDetailJson(data);
  }

  Future<AsignaturaItem> createAsignatura(Map<String, dynamic> payload) async {
    final data = await ApiService.post('$_asig/crear/',
        data: payload, token: await _token()) as Map<String, dynamic>;
    return AsignaturaItem.fromDetailJson(data);
  }

  Future<AsignaturaItem> updateAsignatura(int id, Map<String, dynamic> payload) async {
    final data = await ApiService.patch('$_asig/$id/editar/',
        data: payload, token: await _token()) as Map<String, dynamic>;
    return AsignaturaItem.fromDetailJson(data);
  }

  Future<void> deleteAsignatura(int id) async =>
      ApiService.delete('$_asig/$id/eliminar/', token: await _token());

  // ── Competencias ──────────────────────────────────────────────────────────

  Future<PaginatedResponse<CompetenciaItem>> listCompetencias({
    String? search,
    String? tipo,
    int?    asignatura,
    int     page     = 1,
    int     pageSize = 20,
  }) async {
    final data = await ApiService.get(
      '$_comp/',
      token: await _token(),
      queryParams: {
        'page':      '$page',
        'page_size': '$pageSize',
        if (search     != null && search.isNotEmpty) 'search':     search,
        if (tipo       != null && tipo.isNotEmpty)   'tipo':       tipo,
        if (asignatura != null)                      'asignatura': '$asignatura',
      },
    ) as Map<String, dynamic>;
    return PaginatedResponse.fromJson(data, CompetenciaItem.fromListJson);
  }

  Future<CompetenciaItem> getCompetencia(int id) async {
    final data = await ApiService.get('$_comp/$id/', token: await _token())
        as Map<String, dynamic>;
    return CompetenciaItem.fromDetailJson(data);
  }

  Future<CompetenciaItem> createCompetenciaPrincipal(Map<String, dynamic> payload) async {
    final data = await ApiService.post('$_comp/crear/',
        data: payload, token: await _token()) as Map<String, dynamic>;
    return CompetenciaItem.fromDetailJson(data);
  }

  Future<CompetenciaItem> createCompetenciaTransversal(Map<String, dynamic> payload) async {
    final data = await ApiService.post('$_trans/crear/',
        data: payload, token: await _token()) as Map<String, dynamic>;
    return CompetenciaItem.fromDetailJson(data);
  }

  Future<CompetenciaItem> updateCompetencia(int id, Map<String, dynamic> payload) async {
    final data = await ApiService.patch('$_comp/$id/editar/',
        data: payload, token: await _token()) as Map<String, dynamic>;
    return CompetenciaItem.fromDetailJson(data);
  }

  Future<void> deleteCompetencia(int id) async =>
      ApiService.delete('$_comp/$id/eliminar/', token: await _token());

  // ── RAPs ──────────────────────────────────────────────────────────────────

  Future<PaginatedResponse<RapItem>> listRaps({
    String? search,
    int?    competencia,
    int     page     = 1,
    int     pageSize = 20,
  }) async {
    final data = await ApiService.get(
      '$_rap/',
      token: await _token(),
      queryParams: {
        'page':      '$page',
        'page_size': '$pageSize',
        if (search      != null && search.isNotEmpty) 'search':      search,
        if (competencia != null)                       'competencia': '$competencia',
      },
    ) as Map<String, dynamic>;
    return PaginatedResponse.fromJson(data, RapItem.fromListJson);
  }

  Future<RapItem> getRap(int id) async {
    final data = await ApiService.get('$_rap/$id/', token: await _token())
        as Map<String, dynamic>;
    return RapItem.fromDetailJson(data);
  }

  Future<RapItem> createRap(Map<String, dynamic> payload) async {
    final data = await ApiService.post('$_rap/crear/',
        data: payload, token: await _token()) as Map<String, dynamic>;
    return RapItem.fromDetailJson(data);
  }

  Future<RapItem> updateRap(int id, Map<String, dynamic> payload) async {
    final data = await ApiService.patch('$_rap/$id/editar/',
        data: payload, token: await _token()) as Map<String, dynamic>;
    return RapItem.fromDetailJson(data);
  }

  Future<void> deleteRap(int id) async =>
      ApiService.delete('$_rap/$id/eliminar/', token: await _token());
}
