// lib/features/programa/data/repositories_impl/modulo_repository_impl.dart
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/modulo_entity.dart';
import '../../domain/repositories/modulo_repository.dart';
import '../datasources/modulo_remote_datasource.dart';

class ModuloRepositoryImpl implements ModuloRepository {
  final ModuloRemoteDatasource _datasource;

  ModuloRepositoryImpl({ModuloRemoteDatasource? datasource})
      : _datasource = datasource ?? ModuloRemoteDatasource();

  @override
  Future<PaginatedResponse<ModuloResumenEntity>> list({
    int? versionId,
    int? page,
    int? pageSize,
    String? search,
    ModuloEstado? estado,
  }) async {
    final response = await _datasource.list(
      versionId: versionId,
      page: page,
      pageSize: pageSize,
      search: search,
      estado: estado?.value,
    );
    return PaginatedResponse<ModuloResumenEntity>(
      count: response.count,
      next: response.next,
      previous: response.previous,
      results: response.results.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<ModuloEntity> detail(int id) async {
    final model = await _datasource.detail(id);
    return model.toEntity();
  }

  @override
  Future<ModuloEntity> create({
    required int versionId,
    required String nombre,
    required int orden,
    required int horasLectivas,
    required int horasPracticas,
    String descripcion = '',
    ModuloEstado estado = ModuloEstado.activo,
  }) async {
    final model = await _datasource.create({
      'version': versionId,
      'nombre': nombre,
      'orden': orden,
      'horas_lectivas': horasLectivas,
      'horas_practicas': horasPracticas,
      'descripcion': descripcion,
      'estado': estado.value,
    });
    return model.toEntity();
  }

  @override
  Future<ModuloEntity> update({
    required int id,
    String? nombre,
    int? orden,
    int? horasLectivas,
    int? horasPracticas,
    String? descripcion,
    ModuloEstado? estado,
  }) async {
    final model = await _datasource.update(id, {
      if (nombre != null) 'nombre': nombre,
      if (orden != null) 'orden': orden,
      if (horasLectivas != null) 'horas_lectivas': horasLectivas,
      if (horasPracticas != null) 'horas_practicas': horasPracticas,
      if (descripcion != null) 'descripcion': descripcion,
      if (estado != null) 'estado': estado.value,
    });
    return model.toEntity();
  }
}
