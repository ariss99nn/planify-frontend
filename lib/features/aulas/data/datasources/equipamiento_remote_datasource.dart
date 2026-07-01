// lib/features/aulas/data/datasources/equipamiento_remote_datasource.dart

import 'package:image_picker/image_picker.dart';
import '../../../../core/api/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/paged_result.dart';
import '../models/equipamiento_model.dart';

class EquipamientoRemoteDatasource {
  static Future<String?> _token() => TokenStorage.getAccessToken();

  Future<PagedResult<EquipamientoResumenModel>> getEquipamientos({
    String? search,
    String? estado,
    int page = 1,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (estado != null) 'estado': estado,
    };
    final data = await ApiService.get(
      '/equipamiento/',
      token: await _token(),
      queryParams: params,
    ) as Map<String, dynamic>;
    return PagedResult(
      items: (data['results'] as List)
          .map((e) => EquipamientoResumenModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasNext: data['next'] != null,
      count: data['count'] as int?,
    );
  }

  /// Trae el catálogo COMPLETO de equipamientos (todas las páginas).
  /// Se usa en el multi-select del formulario de aula.
  Future<List<EquipamientoResumenModel>> getAllEquipamientos({
    String? search,
    String? estado,
  }) async {
    final all = <EquipamientoResumenModel>[];
    var page = 1;
    const maxPages = 200;
    while (page <= maxPages) {
      final result = await getEquipamientos(search: search, estado: estado, page: page);
      all.addAll(result.items);
      if (!result.hasNext) break;
      page++;
    }
    return all;
  }

  Future<EquipamientoDetalleModel> getEquipamiento(int id) async {
    final data = await ApiService.get(
      '/equipamiento/$id/',
      token: await _token(),
    ) as Map<String, dynamic>;
    return EquipamientoDetalleModel.fromJson(data);
  }

  Future<EquipamientoDetalleModel> createEquipamiento(
    Map<String, String> fields, {
    XFile? imagen,
  }) async {
    if (imagen != null) {
      final data = await ApiService.postMultipart(
        '/equipamiento/create/',
        fields: fields,
        xfile: imagen,
        xfileField: 'imagen',
        token: await _token(),
      ) as Map<String, dynamic>;
      return EquipamientoDetalleModel.fromJson(data);
    }
    final data = await ApiService.post(
      '/equipamiento/create/',
      data: Map<String, dynamic>.from(fields),
      token: await _token(),
    ) as Map<String, dynamic>;
    return EquipamientoDetalleModel.fromJson(data);
  }

  Future<EquipamientoDetalleModel> updateEquipamiento(
    int id,
    Map<String, String> fields, {
    XFile? imagen,
  }) async {
    if (imagen != null) {
      final data = await ApiService.patchMultipart(
        '/equipamiento/$id/update/',
        fields: fields,
        xfile: imagen,
        xfileField: 'imagen',
        token: await _token(),
      ) as Map<String, dynamic>;
      return EquipamientoDetalleModel.fromJson(data);
    }
    final data = await ApiService.patch(
      '/equipamiento/$id/update/',
      data: Map<String, dynamic>.from(fields),
      token: await _token(),
    ) as Map<String, dynamic>;
    return EquipamientoDetalleModel.fromJson(data);
  }
}