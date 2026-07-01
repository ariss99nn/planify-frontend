// lib/features/programa/domain/usecases/modulo/obtener_modulo_usecase.dart
import '../../entities/modulo_entity.dart';
import '../../repositories/modulo_repository.dart';

class ObtenerModuloUseCase {
  final ModuloRepository repository;
  const ObtenerModuloUseCase(this.repository);

  Future<ModuloEntity> call(int id) => repository.detail(id);
}
