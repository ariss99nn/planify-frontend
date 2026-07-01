// lib/features/programa/data/datasources/modulo_remote_datasource.dart
import '../../../../core/api/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/models/paginated_response.dart';
import '../models/modulo_model.dart';

/// Capa HTTP pura para /modulos/.
class ModuloRemoteDatasource {
  static const String _basePath = '/modulos';

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

  Future<PaginatedResponse<ModuloResumenModel>> list({
    int? versionId,
    int? page,
    int? pageSize,
    String? search,
    String? estado,
  }) async {
    final token = await _requireToken();
    final query = <String, String>{
      if (page != null) 'page': '$page',
      if (pageSize != null) 'page_size': '$pageSize',
      if (search != null && search.isNotEmpty) 'search': search,
      if (versionId != null) 'version': '$versionId',
      if (estado != null) 'estado': estado,
    };
    final json = await ApiService.get(
      '$_basePath/',
      token: token,
      queryParams: query,
    );
    return PaginatedResponse.fromJson(
      json as Map<String, dynamic>,
      ModuloResumenModel.fromJson,
    );
  }

  Future<ModuloModel> detail(int id) async {
    final token = await _requireToken();
    final json = await ApiService.get('$_basePath/$id/', token: token);
    return ModuloModel.fromJson(json as Map<String, dynamic>);
  }

  Future<ModuloModel> create(Map<String, dynamic> data) async {
    final token = await _requireToken();
    final json = await ApiService.post(
      '$_basePath/create/',
      token: token,
      data: data,
    );
    return ModuloModel.fromJson(json as Map<String, dynamic>);
  }

  Future<ModuloModel> update(int id, Map<String, dynamic> data) async {
    final token = await _requireToken();
    final json = await ApiService.patch(
      '$_basePath/$id/update/',
      token: token,
      data: data,
    );
    return ModuloModel.fromJson(json as Map<String, dynamic>);
  }
}
