import '../../../../core/api/api_service.dart';

class ReporteRemoteDatasource {
  static const String _basePath = '/reportes';

  static Future<Map<String, dynamic>> solicitar({
    required String token,
    required String tipo,
    Map<String, dynamic> filtros = const {},
  }) async {
    final response = await ApiService.post(
      '$_basePath/solicitar/',
      token: token,
      data: {'tipo': tipo, 'filtros': filtros},
    );
    return response as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> obtenerEstado({
    required String token,
    required int id,
  }) async {
    final response = await ApiService.get('$_basePath/$id/', token: token);
    return response as Map<String, dynamic>;
  }
}
