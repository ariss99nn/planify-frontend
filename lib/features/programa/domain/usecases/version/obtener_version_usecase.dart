// lib/features/programa/domain/usecases/version/obtener_version_usecase.dart
import '../../entities/version_programa_entity.dart';
import '../../repositories/version_repository.dart';

class ObtenerVersionUseCase {
  final VersionRepository repository;
  const ObtenerVersionUseCase(this.repository);

  Future<VersionEntity> call(int id) => repository.detail(id);
}
