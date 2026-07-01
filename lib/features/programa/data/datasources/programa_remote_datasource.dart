// lib/features/programa/data/datasources/programa_remote_datasource.dart
import '../../../../core/api/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/models/paginated_response.dart';
import '../models/programa_model.dart';

/// Capa HTTP pura para /programas/: arma las llamadas, conoce el token
/// de sesión y no conoce entidades de dominio.
class ProgramaRemoteDatasource {
  static const String _basePath = '/programas';

  Future<String> _requireToken() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      throw ApiException(
        message: 'No has iniciado sesión.',
        statusCode: 401,
        code: 'no_token',
      );
    }
    return token;
  }

  Future<PaginatedResponse<ProgramaResumenModel>> list({
    int? page,
    int? pageSize,
    String? search,
    String? nivel,
    String? estado,
  }) async {
    final token = await _requireToken();
    final query = <String, String>{
      if (page != null) 'page': '$page',
      if (pageSize != null) 'page_size': '$pageSize',
      if (search != null && search.isNotEmpty) 'search': search,
      if (nivel != null) 'nivel': nivel,
      if (estado != null) 'estado': estado,
    };
    final json = await ApiService.get(
      '$_basePath/',
      token: token,
      queryParams: query,
    );
    return PaginatedResponse.fromJson(
      json as Map<String, dynamic>,
      ProgramaResumenModel.fromJson,
    );
  }

  Future<ProgramaModel> detail(int id) async {
    final token = await _requireToken();
    final json = await ApiService.get('$_basePath/$id/', token: token);
    return ProgramaModel.fromJson(json as Map<String, dynamic>);
  }

  Future<ProgramaModel> create(Map<String, dynamic> data) async {
    final token = await _requireToken();
    final json = await ApiService.post(
      '$_basePath/create/',
      token: token,
      data: data,
    );
    return ProgramaModel.fromJson(json as Map<String, dynamic>);
  }

  Future<ProgramaModel> update(int id, Map<String, dynamic> data) async {
    final token = await _requireToken();
    final json = await ApiService.patch(
      '$_basePath/$id/update/',
      token: token,
      data: data,
    );
    return ProgramaModel.fromJson(json as Map<String, dynamic>);
  }
}
