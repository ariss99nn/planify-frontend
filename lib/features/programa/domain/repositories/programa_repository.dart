// lib/features/programa/domain/repositories/programa_repository.dart
import '../../../../core/models/paginated_response.dart';
import '../entities/programa_entity.dart';

abstract class ProgramaRepository {
  Future<PaginatedResponse<ProgramaResumenEntity>> list({
    int? page,
    int? pageSize,
    String? search,
    ProgramaNivel? nivel,
    ProgramaEstado? estado,
  });

  Future<ProgramaEntity> detail(int id);

  Future<ProgramaEntity> create({
    required String nombre,
    String descripcion,
    required ProgramaNivel nivel,
    required int horasLectivas,
    required int horasPracticas,
    ProgramaEstado estado,
    int trimestresTotales,
    ProgramaTipoFormacion tipoFormacion,
    int? trimestresCadena,
  });

  Future<ProgramaEntity> update({
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
  });
}
