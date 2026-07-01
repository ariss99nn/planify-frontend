import '../../../../core/api/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/reporte_generado_entity.dart';
import '../../domain/repositories/reporte_repository.dart';
import '../datasources/reporte_remote_datasource.dart';
import '../models/reporte_generado_model.dart';

class ReporteRepositoryImpl implements ReporteRepository {
  Future<String> _requireToken() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      throw ApiException(
        message: 'Sesión expirada.',
        statusCode: 401,
        code: 'session_expired',
      );
    }
    return token;
  }

  @override
  Future<ReporteGeneradoEntity> solicitarReporte({
    required ReporteTipo tipo,
    Map<String, dynamic> filtros = const {},
  }) async {
    final token = await _requireToken();
    final json = await ReporteRemoteDatasource.solicitar(
      token: token,
      tipo: tipo.value,
      filtros: filtros,
    );
    return ReporteGeneradoModel.fromJson(json);
  }

  @override
  Future<ReporteGeneradoEntity> obtenerEstado(int id) async {
    final token = await _requireToken();
    final json =
        await ReporteRemoteDatasource.obtenerEstado(token: token, id: id);
    return ReporteGeneradoModel.fromJson(json);
  }
}
