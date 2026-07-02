import '../repositories/auditoria_repository.dart';

class GetAuditLogUseCase {
  final AuditoriaRepository _repository;
  const GetAuditLogUseCase(this._repository);

  Future<AuditLogPageEntity> call({
    int page = 1,
    String? metodo,
    String? path,
    int? usuarioId,
  }) =>
      _repository.getAuditLog(
        page: page,
        metodo: metodo,
        path: path,
        usuarioId: usuarioId,
      );
}
