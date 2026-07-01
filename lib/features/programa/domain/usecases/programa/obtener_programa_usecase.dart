// lib/features/programa/domain/usecases/programa/obtener_programa_usecase.dart
import '../../entities/programa_entity.dart';
import '../../repositories/programa_repository.dart';

class ObtenerProgramaUseCase {
  final ProgramaRepository repository;
  const ObtenerProgramaUseCase(this.repository);

  Future<ProgramaEntity> call(int id) => repository.detail(id);
}
