// lib/features/aulas/domain/usecases/aula/actualizar_estado_aula_usecase.dart

import '../../repositories/aula_repository.dart';

class ActualizarEstadoAulaUseCase {
  final AulaRepository repository;
  const ActualizarEstadoAulaUseCase(this.repository);

  Future<void> call(int id, String estado) => repository.updateEstado(id, estado);
}