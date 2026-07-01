// lib/features/programa/data/repositories_impl/programa_repository_impl.dart
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/programa_entity.dart';
import '../../domain/repositories/programa_repository.dart';
import '../datasources/programa_remote_datasource.dart';

class ProgramaRepositoryImpl implements ProgramaRepository {
  final ProgramaRemoteDatasource _datasource;

  ProgramaRepositoryImpl({ProgramaRemoteDatasource? datasource})
      : _datasource = datasource ?? ProgramaRemoteDatasource();

  @override
  Future<PaginatedResponse<ProgramaResumenEntity>> list({
    int? page,
    int? pageSize,
    String? search,
    ProgramaNivel? nivel,
    ProgramaEstado? estado,
  }) async {
    final response = await _datasource.list(
      page: page,
      pageSize: pageSize,
      search: search,
      nivel: nivel?.value,
      estado: estado?.value,
    );
    return PaginatedResponse<ProgramaResumenEntity>(
      count: response.count,
      next: response.next,
      previous: response.previous,
      results: response.results.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<ProgramaEntity> detail(int id) async {
    final model = await _datasource.detail(id);
    return model.toEntity();
  }

  @override
  Future<ProgramaEntity> create({
    required String nombre,
    String descripcion = '',
    required ProgramaNivel nivel,
    required int horasLectivas,
    required int horasPracticas,
    ProgramaEstado estado = ProgramaEstado.activo,
    int trimestresTotales = 6,
    ProgramaTipoFormacion tipoFormacion = ProgramaTipoFormacion.porOferta,
    int? trimestresCadena,
  }) async {
    final model = await _datasource.create({
      'nombre': nombre,
      'descripcion': descripcion,
      'nivel': nivel.value,
      'horas_lectivas': horasLectivas,
      'horas_practicas': horasPracticas,
      'estado': estado.value,
      'trimestres_totales': trimestresTotales,
      'tipo_formacion': tipoFormacion.value,
      if (trimestresCadena != null) 'trimestres_cadena': trimestresCadena,
    });
    return model.toEntity();
  }

  @override
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
  }) async {
    final model = await _datasource.update(id, {
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (nivel != null) 'nivel': nivel.value,
      if (horasLectivas != null) 'horas_lectivas': horasLectivas,
      if (horasPracticas != null) 'horas_practicas': horasPracticas,
      if (estado != null) 'estado': estado.value,
      if (trimestresTotales != null) 'trimestres_totales': trimestresTotales,
      if (tipoFormacion != null) 'tipo_formacion': tipoFormacion.value,
      if (trimestresCadena != null) 'trimestres_cadena': trimestresCadena,
    });
    return model.toEntity();
  }
}
