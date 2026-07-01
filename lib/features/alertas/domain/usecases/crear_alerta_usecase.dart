import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/alerta_entity.dart';
import '../repositories/alerta_repository.dart';

class CrearAlertaUseCase {
  final AlertaRepository _repository;

  const CrearAlertaUseCase(this._repository);

  Future<Either<Failure, AlertaEntity>> call({
    required String tipo,
    required String descripcion,
    required String formatoAlerta,
    int? destinatario,
    int? bloqueOrigen,
  }) {
    return _repository.crear(
      tipo: tipo,
      descripcion: descripcion,
      formatoAlerta: formatoAlerta,
      destinatario: destinatario,
      bloqueOrigen: bloqueOrigen,
    );
  }
}

class CrearAlertaPorRolUseCase {
  final AlertaRepository _repository;

  const CrearAlertaPorRolUseCase(this._repository);

  Future<Either<Failure, List<AlertaEntity>>> call({
    required String tipo,
    required String descripcion,
    required String formatoAlerta,
    required String destinatarioRol,
    int? bloqueOrigen,
  }) {
    return _repository.crearPorRol(
      tipo: tipo,
      descripcion: descripcion,
      formatoAlerta: formatoAlerta,
      destinatarioRol: destinatarioRol,
      bloqueOrigen: bloqueOrigen,
    );
  }
}
