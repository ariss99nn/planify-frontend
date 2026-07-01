// lib/features/programa/domain/usecases/modulo/crear_modulo_usecase.dart
import '../../entities/modulo_entity.dart';
import '../../repositories/modulo_repository.dart';

class CrearModuloUseCase {
  final ModuloRepository repository;
  const CrearModuloUseCase(this.repository);

  Future<ModuloEntity> call({
    required int versionId,
    required String nombre,
    required int orden,
    required int horasLectivas,
    required int horasPracticas,
    String descripcion = '',
    ModuloEstado estado = ModuloEstado.activo,
  }) =>
      repository.create(
        versionId: versionId,
        nombre: nombre,
        orden: orden,
        horasLectivas: horasLectivas,
        horasPracticas: horasPracticas,
        descripcion: descripcion,
        estado: estado,
      );
}
