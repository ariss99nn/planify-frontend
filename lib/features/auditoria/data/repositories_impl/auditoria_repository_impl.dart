import '../../domain/entities/auditoria_entity.dart';
import '../../domain/repositories/auditoria_repository.dart';
import '../datasources/auditoria_remote_datasource.dart';

class AuditoriaRepositoryImpl implements AuditoriaRepository {
  final AuditoriaRemoteDataSource _dataSource;
  const AuditoriaRepositoryImpl(this._dataSource);

  @override
  Future<AuditLogPageEntity> getAuditLog({
    int page = 1,
    String? metodo,
    String? path,
    int? usuarioId,
  }) async {
    final pageModel = await _dataSource.getAuditLog(
      page: page,
      metodo: metodo,
      path: path,
      usuarioId: usuarioId,
    );
    return AuditLogPageEntity(
      items: pageModel.items.map((m) => m.toEntity()).toList(),
      total: pageModel.total,
      hasNext: pageModel.hasNext,
    );
  }
}
