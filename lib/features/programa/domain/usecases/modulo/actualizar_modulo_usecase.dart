// lib/features/programa/domain/usecases/modulo/actualizar_modulo_usecase.dart
import '../../entities/modulo_entity.dart';
import '../../repositories/modulo_repository.dart';

class ActualizarModuloUseCase {
  final ModuloRepository repository;
  const ActualizarModuloUseCase(this.repository);

  Future<ModuloEntity> call({
    required int id,
    String? nombre,
    int? orden,
    int? horasLectivas,
    int? horasPracticas,
    String? descripcion,
    ModuloEstado? estado,
  }) =>
      repository.update(
        id: id,
        nombre: nombre,
        orden: orden,
        horasLectivas: horasLectivas,
        horasPracticas: horasPracticas,
        descripcion: descripcion,
        estado: estado,
      );
}
