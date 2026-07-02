// lib/features/ficha/data/datasources/estudiante_bloqueo_remote_datasource.dart

import '../../../../core/api/api_service.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/estudiante_bloqueo_model.dart';

class EstudianteBloqueoRemoteDatasource {
  static Future<String?> _token() => TokenStorage.getAccessToken();

  Future<PaginatedResponse<EstudianteBloqueoModel>> getBloqueos({
    bool? activo,
    int page     = 1,
    int pageSize = 20,
  }) async {
    final params = <String, String>{
      'page':      page.toString(),
      'page_size': pageSize.toString(),
      if (activo != null) 'activo': activo.toString(),
    };
    final data = await ApiService.get(
      '/fichas/bloqueos/',
      token: await _token(),
      queryParams: params,
    ) as Map<String, dynamic>;
    return PaginatedResponse.fromJson(data, EstudianteBloqueoModel.fromJson);
  }

  Future<EstudianteBloqueoModel> desbloquear(
    int id, {
    String observacion = '',
  }) async {
    final data = await ApiService.post(
      '/fichas/bloqueos/$id/desbloquear/',
      token: await _token(),
      data: {'confirmar': true, 'observacion': observacion},
    ) as Map<String, dynamic>;
    return EstudianteBloqueoModel.fromJson(data);
  }
}
