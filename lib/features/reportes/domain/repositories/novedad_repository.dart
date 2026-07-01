import '../../../../core/models/paginated_response.dart';
import '../entities/novedad_entity.dart';

abstract class NovedadRepository {
  Future<PaginatedResponse<NovedadEntity>> obtenerNovedades({
    bool? atendida,
    String? tipo,
    int page = 1,
  });

  Future<NovedadEntity> crearNovedad(NovedadCreateInput input);

  Future<NovedadEntity> atenderNovedad({
    required int id,
    required String notaAtencion,
  });
}
