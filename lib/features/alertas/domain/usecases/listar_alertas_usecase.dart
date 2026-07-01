import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/alerta_entity.dart';
import '../repositories/alerta_repository.dart';

class ListarAlertasUseCase {
  final AlertaRepository _repository;

  const ListarAlertasUseCase(this._repository);

  Future<Either<Failure, AlertaPage>> call(AlertaFiltros filtros) {
    return _repository.listar(filtros);
  }
}
