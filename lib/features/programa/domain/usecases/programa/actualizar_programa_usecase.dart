// lib/features/programa/domain/usecases/programa/actualizar_programa_usecase.dart
import '../../entities/programa_entity.dart';
import '../../repositories/programa_repository.dart';

class ActualizarProgramaUseCase {
  final ProgramaRepository repository;
  const ActualizarProgramaUseCase(this.repository);

  Future<ProgramaEntity> call({
    required int id,
    String? nombre,
    String? descripcion,
    ProgramaNivel? nivel,
    int? horasLectivas,
    int? horasPracticas,
    ProgramaEstado? estado,
    int? trimestresTotales,
    ProgramaTipoFormacion? tipoFormacion,
    int? trimestresCadena,
  }) =>
      repository.update(
        id: id,
        nombre: nombre,
        descripcion: descripcion,
        nivel: nivel,
        horasLectivas: horasLectivas,
        horasPracticas: horasPracticas,
        estado: estado,
        trimestresTotales: trimestresTotales,
        tipoFormacion: tipoFormacion,
        trimestresCadena: trimestresCadena,
      );
}
