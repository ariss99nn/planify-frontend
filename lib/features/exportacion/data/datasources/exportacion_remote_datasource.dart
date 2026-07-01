import 'dart:typed_data';
import '../../../../core/api/api_service.dart';

abstract class ExportacionRemoteDatasource {
  Future<Uint8List> downloadExport({
    required String              modulo,
    required String              formato,
    required Map<String, String> filtros,
    required String              token,
  });

  Future<Map<String, dynamic>> fetchLog({
    required String token,
    int     page     = 1,
    int     pageSize = 20,
    String? tipo,
  });
}

class ExportacionRemoteDatasourceImpl implements ExportacionRemoteDatasource {
  const ExportacionRemoteDatasourceImpl();

  @override
  Future<Uint8List> downloadExport({
    required String              modulo,
    required String              formato,
    required Map<String, String> filtros,
    required String              token,
  }) =>
      ApiService.downloadFile(
        '/exportar/',
        data: {
          'modulo':  modulo,
          'formato': formato,
          'filtros': filtros,
        },
        token: token,
      );

  @override
  Future<Map<String, dynamic>> fetchLog({
    required String token,
    int     page     = 1,
    int     pageSize = 20,
    String? tipo,
  }) async {
    final params = <String, String>{
      'page':      page.toString(),
      'page_size': pageSize.toString(),
      if (tipo != null && tipo.isNotEmpty) 'tipo': tipo,
    };

    final data = await ApiService.get(
      '/exportaciones/log/',
      token:       token,
      queryParams: params,
    );

    return data as Map<String, dynamic>;
  }
}
