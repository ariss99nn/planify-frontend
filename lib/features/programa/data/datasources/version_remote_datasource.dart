// lib/features/programa/data/datasources/version_remote_datasource.dart
import '../../../../core/api/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/models/paginated_response.dart';
import '../models/version_programa_model.dart';

/// Capa HTTP pura para /versiones/.
class VersionRemoteDatasource {
  static const String _basePath = '/versiones';

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

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<PaginatedResponse<VersionResumenModel>> list({
    int? programaId,
    int? page,
    int? pageSize,
    String? search,
    bool? vigente,
  }) async {
    final token = await _requireToken();
    final query = <String, String>{
      if (page != null) 'page': '$page',
      if (pageSize != null) 'page_size': '$pageSize',
      if (search != null && search.isNotEmpty) 'search': search,
      if (programaId != null) 'programa': '$programaId',
      if (vigente != null) 'vigente': vigente.toString(),
    };
    final json = await ApiService.get(
      '$_basePath/',
      token: token,
      queryParams: query,
    );
    return PaginatedResponse.fromJson(
      json as Map<String, dynamic>,
      VersionResumenModel.fromJson,
    );
  }

  Future<VersionModel> detail(int id) async {
    final token = await _requireToken();
    final json = await ApiService.get('$_basePath/$id/', token: token);
    return VersionModel.fromJson(json as Map<String, dynamic>);
  }

  Future<VersionModel> create({
    required int programaId,
    required int numero,
    String descripcion = '',
    bool vigente = false,
    required DateTime fechaInicio,
    DateTime? fechaFin,
  }) async {
    final token = await _requireToken();
    final json = await ApiService.post(
      '$_basePath/create/',
      token: token,
      data: {
        'programa': programaId,
        'numero': numero,
        'descripcion': descripcion,
        'vigente': vigente,
        'fecha_inicio': _fmt(fechaInicio),
        if (fechaFin != null) 'fecha_fin': _fmt(fechaFin),
      },
    );
    return VersionModel.fromJson(json as Map<String, dynamic>);
  }

  Future<VersionModel> update({
    required int id,
    String? descripcion,
    bool? vigente,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    final token = await _requireToken();
    final json = await ApiService.patch(
      '$_basePath/$id/update/',
      token: token,
      data: {
        if (descripcion != null) 'descripcion': descripcion,
        if (vigente != null) 'vigente': vigente,
        if (fechaInicio != null) 'fecha_inicio': _fmt(fechaInicio),
        if (fechaFin != null) 'fecha_fin': _fmt(fechaFin),
      },
    );
    return VersionModel.fromJson(json as Map<String, dynamic>);
  }
}
