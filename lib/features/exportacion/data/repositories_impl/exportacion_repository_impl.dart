import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../../../../core/api/api_service.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/exportacion_enums.dart';
import '../../domain/entities/export_result.dart';
import '../../domain/entities/registro_exportacion_entity.dart';
import '../../domain/repositories/exportacion_repository.dart';
import '../datasources/exportacion_remote_datasource.dart';
import '../models/registro_exportacion_model.dart';

class ExportacionRepositoryImpl implements ExportacionRepository {
  final ExportacionRemoteDatasource _datasource;

  ExportacionRepositoryImpl({ExportacionRemoteDatasource? datasource})
      : _datasource = datasource ?? const ExportacionRemoteDatasourceImpl();

  @override
  Future<ExportResult> exportar({
    required TipoExportacion     modulo,
    required FormatoExportacion  formato,
    required Map<String, String> filtros,
  }) async {
    final token = await _requireToken();
    final bytes = await _datasource.downloadExport(
      modulo:  modulo.value,
      formato: formato.value,
      filtros: filtros,
      token:   token,
    );
    final file = await _persist(bytes, modulo, formato);
    return ExportResult(file: file, fileName: file.uri.pathSegments.last);
  }

  @override
  Future<PaginatedResponse<RegistroExportacionEntity>> getLog({
    int              page     = 1,
    int              pageSize = 20,
    TipoExportacion? tipo,
  }) async {
    final token = await _requireToken();
    final json  = await _datasource.fetchLog(
      token:    token,
      page:     page,
      pageSize: pageSize,
      tipo:     tipo?.value,
    );
    return PaginatedResponse.fromJson(json, RegistroExportacionModel.fromJson);
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<String> _requireToken() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw ApiException(
        message:    'Sin sesión activa. Inicia sesión nuevamente.',
        statusCode: 401,
        code:       'no_token',
      );
    }
    return token;
  }

  Future<File> _persist(
    Uint8List          bytes,
    TipoExportacion    modulo,
    FormatoExportacion formato,
  ) async {
    final dir   = await getTemporaryDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final name  = '${modulo.value.toLowerCase()}_$stamp.${formato.extension}';
    final file  = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
