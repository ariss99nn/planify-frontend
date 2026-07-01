import '../../../../core/api/api_service.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/novedad_entity.dart';
import '../../domain/repositories/novedad_repository.dart';
import '../datasources/novedad_remote_datasource.dart';
import '../models/novedad_model.dart';

class NovedadRepositoryImpl implements NovedadRepository {
  Future<String> _requireToken() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      throw ApiException(
        message: 'Sesión expirada. Inicia sesión nuevamente.',
        statusCode: 401,
        code: 'session_expired',
      );
    }
    return token;
  }

  @override
  Future<PaginatedResponse<NovedadEntity>> obtenerNovedades({
    bool? atendida,
    String? tipo,
    int page = 1,
  }) async {
    final token = await _requireToken();
    final json = await NovedadRemoteDatasource.listar(
      token: token,
      atendida: atendida,
      tipo: tipo,
      page: page,
    );
    return PaginatedResponse.fromJson(json, NovedadModel.fromJson);
  }

  @override
  Future<NovedadEntity> crearNovedad(NovedadCreateInput input) async {
    final token = await _requireToken();
    final json = await NovedadRemoteDatasource.crear(
      token: token,
      payload: input.toJson(),
    );
    return NovedadModel.fromJson(json);
  }

  @override
  Future<NovedadEntity> atenderNovedad({
    required int id,
    required String notaAtencion,
  }) async {
    final token = await _requireToken();
    final json = await NovedadRemoteDatasource.atender(
      token: token,
      id: id,
      notaAtencion: notaAtencion,
    );
    return NovedadModel.fromJson(json);
  }
}
