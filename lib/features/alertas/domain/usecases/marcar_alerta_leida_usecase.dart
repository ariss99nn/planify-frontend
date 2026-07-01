import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/alerta_entity.dart';
import '../repositories/alerta_repository.dart';

class MarcarAlertaLeidaUseCase {
  final AlertaRepository _repository;

  const MarcarAlertaLeidaUseCase(this._repository);

  /// Marca la alerta como leída, validando que:
  /// 1. La alerta no esté ya leída (optimización: evita llamada innecesaria).
  /// 2. El [currentUserId] sea el destinatario (autorización de dominio).
  Future<Either<Failure, AlertaEntity>> call({
    required AlertaEntity alerta,
    required int currentUserId,
  }) async {
    if (alerta.isLeida) {
      return Right(alerta); // idempotente: ya está leída, sin red call
    }

    if (!alerta.esDe(currentUserId)) {
      return const Left(
        AuthorizationFailure('No puedes marcar como leída una alerta ajena.'),
      );
    }

    return _repository.marcarLeida(alerta.id);
  }
}
