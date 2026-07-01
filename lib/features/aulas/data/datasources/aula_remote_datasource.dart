// lib/features/aulas/data/datasources/aula_remote_datasource.dart

import 'package:image_picker/image_picker.dart';
import '../../../../core/api/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/paged_result.dart';
import '../models/aula_model.dart';

class AulaRemoteDatasource {
  static Future<String?> _token() => TokenStorage.getAccessToken();

  Future<PagedResult<AulaResumenModel>> getAulas({
    String? search,
    String? estado,
    String? tipoAula,
    int? bloqueId,
    int page = 1,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (estado != null) 'estado': estado,
      if (tipoAula != null) 'tipo_aula': tipoAula,
      if (bloqueId != null) 'bloque': bloqueId.toString(),
    };
    final data = await ApiService.get(
      '/aulas/',
      token: await _token(),
      queryParams: params,
    ) as Map<String, dynamic>;
    return PagedResult(
      items: (data['results'] as List)
          .map((e) => AulaResumenModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasNext: data['next'] != null,
      count: data['count'] as int?,
    );
  }

  Future<AulaModel> getAula(int id) async {
    final data = await ApiService.get(
      '/aulas/$id/',
      token: await _token(),
    ) as Map<String, dynamic>;
    return AulaModel.fromJson(data);
  }

  Future<AulaModel> createAula(
    Map<String, String> fields, {
    XFile? imagen,
    List<int> equipamientoIds = const [],
  }) async {
    if (imagen != null) {
      final raw = await ApiService.postMultipart(
        '/aulas/create/',
        fields: fields,
        xfile: imagen,
        xfileField: 'imagen',
        token: await _token(),
      ) as Map<String, dynamic>;
      final aula = AulaModel.fromJson(raw);
      final patched = await ApiService.patch(
        '/aulas/${aula.id}/update/',
        data: {'equipamiento': equipamientoIds},
        token: await _token(),
      ) as Map<String, dynamic>;
      return AulaModel.fromJson(patched);
    }
    final data = await ApiService.post(
      '/aulas/create/',
      data: <String, dynamic>{
        ...Map<String, dynamic>.from(fields),
        'equipamiento': equipamientoIds,
      },
      token: await _token(),
    ) as Map<String, dynamic>;
    return AulaModel.fromJson(data);
  }

  Future<AulaModel> updateAula(
    int id,
    Map<String, String> fields, {
    XFile? imagen,
    List<int> equipamientoIds = const [],
  }) async {
    if (imagen != null) {
      final raw = await ApiService.patchMultipart(
        '/aulas/$id/update/',
        fields: fields,
        xfile: imagen,
        xfileField: 'imagen',
        token: await _token(),
      ) as Map<String, dynamic>;
      final aula = AulaModel.fromJson(raw);
      final patched = await ApiService.patch(
        '/aulas/$id/update/',
        data: {'equipamiento': equipamientoIds},
        token: await _token(),
      ) as Map<String, dynamic>;
      return AulaModel.fromJson(patched);
    }
    final data = await ApiService.patch(
      '/aulas/$id/update/',
      data: <String, dynamic>{
        ...Map<String, dynamic>.from(fields),
        'equipamiento': equipamientoIds,
      },
      token: await _token(),
    ) as Map<String, dynamic>;
    return AulaModel.fromJson(data);
  }

  Future<void> updateEstado(int id, String estado) async {
    await ApiService.patch(
      '/aulas/$id/estado/',
      data: {'estado': estado},
      token: await _token(),
    );
  }
}