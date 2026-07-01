import '../../../../core/models/paginated_response.dart';
import '../entities/novedad_entity.dart';
import '../repositories/novedad_repository.dart';

class ObtenerNovedadesUseCase {
  final NovedadRepository _repo;
  const ObtenerNovedadesUseCase(this._repo);

  Future<PaginatedResponse<NovedadEntity>> call({
    bool? atendida,
    String? tipo,
    int page = 1,
  }) =>
      _repo.obtenerNovedades(atendida: atendida, tipo: tipo, page: page);
}

class CrearNovedadUseCase {
  final NovedadRepository _repo;
  const CrearNovedadUseCase(this._repo);

  Future<NovedadEntity> call(NovedadCreateInput input) =>
      _repo.crearNovedad(input);
}

class AtenderNovedadUseCase {
  final NovedadRepository _repo;
  const AtenderNovedadUseCase(this._repo);

  Future<NovedadEntity> call({
    required int id,
    required String notaAtencion,
  }) =>
      _repo.atenderNovedad(id: id, notaAtencion: notaAtencion);
}
