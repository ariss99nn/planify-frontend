// lib/features/programa/domain/usecases/programa/crear_programa_usecase.dart
import '../../entities/programa_entity.dart';
import '../../repositories/programa_repository.dart';

class CrearProgramaUseCase {
  final ProgramaRepository repository;
  const CrearProgramaUseCase(this.repository);

  Future<ProgramaEntity> call({
    required String nombre,
    String descripcion = '',
    required ProgramaNivel nivel,
    required int horasLectivas,
    required int horasPracticas,
    ProgramaEstado estado = ProgramaEstado.activo,
    int trimestresTotales = 6,
    ProgramaTipoFormacion tipoFormacion = ProgramaTipoFormacion.porOferta,
    int? trimestresCadena,
  }) =>
      repository.create(
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
