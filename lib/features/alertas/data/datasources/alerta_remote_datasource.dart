import '../../../../core/api/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/alerta_model.dart';

/// Resultado de paginación a nivel de datasource (trabaja con Models, no Entities).
class AlertaPageDto {
  final List<AlertaModel> items;
  final int count;
  final bool hasMore;

  const AlertaPageDto({
    required this.items,
    required this.count,
    required this.hasMore,
  });
}

/// Contrato del datasource remoto.
abstract interface class AlertaRemoteDatasource {
  Future<AlertaPageDto> listar({
    String? tipo,
    String? estado,
    bool soloNoLeidas,
    int page,
    int pageSize,
  });

  Future<AlertaModel> marcarLeida(int id);

  Future<AlertaModel> crear({
    required String tipo,
    required String descripcion,
    required String formatoAlerta,
    int? destinatario,
    int? bloqueOrigen,
  });

  Future<List<AlertaModel>> crearPorRol({
    required String tipo,
    required String descripcion,
    required String formatoAlerta,
    required String destinatarioRol,
    int? bloqueOrigen,
  });
}

/// Implementación real que consume la API REST.
/// Usa los métodos estáticos de ApiService y TokenStorage directamente.
class AlertaRemoteDatasourceImpl implements AlertaRemoteDatasource {
  const AlertaRemoteDatasourceImpl();

  static const _base = '/alertas';

  @override
  Future<AlertaPageDto> listar({
    String? tipo,
    String? estado,
    bool soloNoLeidas = false,
    int page = 1,
    int pageSize = 20,
  }) async {
    final token = await TokenStorage.getAccessToken();
    final params = <String, String>{
      if (tipo != null) 'tipo': tipo,
      if (estado != null) 'estado': estado,
      if (soloNoLeidas) 'solo_no_leidas': 'true',
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    final data =
        await ApiService.get('$_base/', token: token, queryParams: params);

    final results = (data['results'] as List<dynamic>)
        .map((e) => AlertaModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return AlertaPageDto(
      items: results,
      count: data['count'] as int,
      hasMore: data['next'] != null,
    );
  }

  @override
  Future<AlertaModel> marcarLeida(int id) async {
    final token = await TokenStorage.getAccessToken();
    final data = await ApiService.patch(
      '$_base/$id/update/',
      token: token,
      data: {'estado': 'LEIDA'},
    );
    return AlertaModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<AlertaModel> crear({
    required String tipo,
    required String descripcion,
    required String formatoAlerta,
    int? destinatario,
    int? bloqueOrigen,
  }) async {
    final token = await TokenStorage.getAccessToken();
    final data = await ApiService.post(
      '$_base/create/',
      token: token,
      data: {
        'tipo': tipo,
        'descripcion': descripcion,
        'formato_alerta': formatoAlerta,
        if (destinatario != null) 'destinatario': destinatario,
        if (bloqueOrigen != null) 'bloque_origen': bloqueOrigen,
      },
    );
    return AlertaModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<AlertaModel>> crearPorRol({
    required String tipo,
    required String descripcion,
    required String formatoAlerta,
    required String destinatarioRol,
    int? bloqueOrigen,
  }) async {
    final token = await TokenStorage.getAccessToken();
    final data = await ApiService.post(
      '$_base/create/',
      token: token,
      data: {
        'tipo': tipo,
        'descripcion': descripcion,
        'formato_alerta': formatoAlerta,
        'destinatario_rol': destinatarioRol,
        if (bloqueOrigen != null) 'bloque_origen': bloqueOrigen,
      },
    );
    return (data as List<dynamic>)
        .map((e) => AlertaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}