// lib/features/programa/domain/usecases/version/actualizar_version_usecase.dart
import '../../entities/version_programa_entity.dart';
import '../../repositories/version_repository.dart';

class ActualizarVersionUseCase {
  final VersionRepository repository;
  const ActualizarVersionUseCase(this.repository);

  Future<VersionEntity> call({
    required int id,
    String? descripcion,
    bool? vigente,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) =>
      repository.update(
        id: id,
        descripcion: descripcion,
        vigente: vigente,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
}
