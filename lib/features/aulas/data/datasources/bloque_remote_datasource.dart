// lib/features/aulas/data/datasources/bloque_remote_datasource.dart

import 'package:image_picker/image_picker.dart';
import '../../../../core/api/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/paged_result.dart';
import '../models/bloque_model.dart';

class BloqueRemoteDatasource {
  static Future<String?> _token() => TokenStorage.getAccessToken();

  Future<PagedResult<BloqueResumenModel>> getBloques({
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
      '/bloques/',
      token: await _token(),
      queryParams: params,
    ) as Map<String, dynamic>;
    return PagedResult(
      items: (data['results'] as List)
          .map((e) => BloqueResumenModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasNext: data['next'] != null,
      count: data['count'] as int?,
    );
  }

  /// Trae el catálogo COMPLETO de bloques (todas las páginas).
  /// Se usa en selectores/dropdowns, donde se necesita la lista entera
  /// y no solo la primera página — evita el crash del DropdownButtonFormField
  /// cuando el bloque seleccionado no está en la página 1.
  Future<List<BloqueResumenModel>> getAllBloques({
    String? search,
    String? estado,
  }) async {
    final all = <BloqueResumenModel>[];
    var page = 1;
    const maxPages = 200; // tope de seguridad ante backends mal configurados
    while (page <= maxPages) {
      final result = await getBloques(search: search, estado: estado, page: page);
      all.addAll(result.items);
      if (!result.hasNext) break;
      page++;
    }
    return all;
  }

  Future<BloqueDetalleModel> getBloque(int id) async {
    final data = await ApiService.get(
      '/bloques/$id/',
      token: await _token(),
    ) as Map<String, dynamic>;
    return BloqueDetalleModel.fromJson(data);
  }

  Future<BloqueDetalleModel> createBloque(
    Map<String, String> fields, {
    XFile? imagen,
  }) async {
    if (imagen != null) {
      final data = await ApiService.postMultipart(
        '/bloques/create/',
        fields: fields,
        xfile: imagen,
        xfileField: 'imagen',
        token: await _token(),
      ) as Map<String, dynamic>;
      return BloqueDetalleModel.fromJson(data);
    }
    final data = await ApiService.post(
      '/bloques/create/',
      data: Map<String, dynamic>.from(fields),
      token: await _token(),
    ) as Map<String, dynamic>;
    return BloqueDetalleModel.fromJson(data);
  }

  Future<BloqueDetalleModel> updateBloque(
    int id,
    Map<String, String> fields, {
    XFile? imagen,
  }) async {
    if (imagen != null) {
      final data = await ApiService.patchMultipart(
        '/bloques/$id/update/',
        fields: fields,
        xfile: imagen,
        xfileField: 'imagen',
        token: await _token(),
      ) as Map<String, dynamic>;
      return BloqueDetalleModel.fromJson(data);
    }
    final data = await ApiService.patch(
      '/bloques/$id/update/',
      data: Map<String, dynamic>.from(fields),
      token: await _token(),
    ) as Map<String, dynamic>;
    return BloqueDetalleModel.fromJson(data);
  }
}