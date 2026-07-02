import '../../../../core/api/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/auditoria_model.dart';

class AuditLogPageModel {
  final List<AuditLogModel> items;
  final int total;
  final bool hasNext;

  const AuditLogPageModel({
    required this.items,
    required this.total,
    required this.hasNext,
  });
}

abstract class AuditoriaRemoteDataSource {
  Future<AuditLogPageModel> getAuditLog({
    int page = 1,
    String? metodo,
    String? path,
    int? usuarioId,
  });
}

class AuditoriaRemoteDataSourceImpl implements AuditoriaRemoteDataSource {
  static const _base = '/auditoria';

  @override
  Future<AuditLogPageModel> getAuditLog({
    int page = 1,
    String? metodo,
    String? path,
    int? usuarioId,
  }) async {
    final token = await TokenStorage.getAccessToken();
    final params = <String, String>{
      'page': page.toString(),
      if (metodo != null) 'metodo': metodo,
      if (path != null && path.isNotEmpty) 'path': path,
      if (usuarioId != null) 'usuario': usuarioId.toString(),
    };
    final data = await ApiService.get('$_base/', token: token, queryParams: params);
    final map = data as Map<String, dynamic>;
    final results = (map['results'] as List<dynamic>)
        .map((e) => AuditLogModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return AuditLogPageModel(
      items: results,
      total: map['count'] as int? ?? results.length,
      hasNext: map['next'] != null,
    );
  }
}
