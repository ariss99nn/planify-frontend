import '../../../../core/api/api_service.dart';

class NovedadRemoteDatasource {
  static const String _basePath = '/novedades';

  static Future<Map<String, dynamic>> listar({
    required String token,
    bool? atendida,
    String? tipo,
    int page = 1,
  }) async {
    final query = <String, String>{'page': '$page'};
    if (atendida != null) query['atendida'] = atendida.toString();
    if (tipo != null) query['tipo'] = tipo;

    final response = await ApiService.get(
      '$_basePath/',
      token: token,
      queryParams: query,
    );
    return response as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> crear({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    final response = await ApiService.post(
      '$_basePath/crear/',
      token: token,
      data: payload,
    );
    return response as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> atender({
    required String token,
    required int id,
    required String notaAtencion,
  }) async {
    final response = await ApiService.patch(
      '$_basePath/$id/atender/',
      token: token,
      data: {'nota_atencion': notaAtencion},
    );
    return response as Map<String, dynamic>;
  }
}
