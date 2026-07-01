// lib/features/programa/domain/usecases/version/crear_version_usecase.dart
import '../../entities/version_programa_entity.dart';
import '../../repositories/version_repository.dart';

class CrearVersionUseCase {
  final VersionRepository repository;
  const CrearVersionUseCase(this.repository);

  Future<VersionEntity> call({
    required int programaId,
    required int numero,
    String descripcion = '',
    bool vigente = false,
    required DateTime fechaInicio,
    DateTime? fechaFin,
  }) =>
      repository.create(
        programaId: programaId,
        numero: numero,
        descripcion: descripcion,
        vigente: vigente,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
}
