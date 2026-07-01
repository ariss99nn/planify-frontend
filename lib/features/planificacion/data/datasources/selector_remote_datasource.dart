// lib/features/planificacion/data/datasources/selector_remote_datasource.dart

import '../../../../core/api/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/selector_models.dart';

class SelectorRemoteDatasource {
  Future<String?> _token() => TokenStorage.getAccessToken();

  Future<List<FichaSelector>> buscarFichas({
    String? query,
    int     pageSize = 20,
  }) async {
    final token  = await _token();
    final params = <String, String>{
      if (query != null && query.isNotEmpty) 'search': query,
      'page_size': '$pageSize',
    };
    final data = await ApiService.get(
      '/fichas/selector/',
      token:       token,
      queryParams: params,
    );
    final list = data is List
        ? data
        : (data as Map<String, dynamic>)['results'] as List<dynamic>? ?? [];
    return list
        .map((e) => FichaSelector.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CompetenciaSelector>> buscarCompetencias({
    String? query,
    int?    asignaturaId,
    bool    soloTransversales = false,
    int     pageSize          = 20,
  }) async {
    final token  = await _token();
    final params = <String, String>{
      if (query        != null && query.isNotEmpty) 'search':     query,
      if (asignaturaId != null) 'asignatura': '$asignaturaId',
      if (soloTransversales)    'transversales': 'true',
      'page_size': '$pageSize',
    };
    final data = await ApiService.get(
      '/competencias/selector/',
      token:       token,
      queryParams: params,
    );
    final list = data is List
        ? data
        : (data as Map<String, dynamic>)['results'] as List<dynamic>? ?? [];
    return list
        .map((e) => CompetenciaSelector.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DocenteSelector>> buscarDocentes({
    String? query,
    bool    soloActivos = true,
    int     pageSize    = 20,
  }) async {
    final token  = await _token();
    final params = <String, String>{
      if (query != null && query.isNotEmpty) 'search': query,
      if (soloActivos) 'activo': 'true',
      'page_size': '$pageSize',
    };
    final data = await ApiService.get(
      '/docentes/selector/',
      token:       token,
      queryParams: params,
    );
    final list = data is List
        ? data
        : (data as Map<String, dynamic>)['results'] as List<dynamic>? ?? [];
    return list
        .map((e) => DocenteSelector.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
