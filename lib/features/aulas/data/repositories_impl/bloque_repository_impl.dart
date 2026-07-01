// lib/features/aulas/data/repositories_impl/bloque_repository_impl.dart

import 'package:image_picker/image_picker.dart';
import '../../domain/entities/bloque_entity.dart';
import '../../domain/entities/paged_result.dart';
import '../../domain/repositories/bloque_repository.dart';
import '../datasources/bloque_remote_datasource.dart';

class BloqueRepositoryImpl implements BloqueRepository {
  final BloqueRemoteDatasource _datasource;
  BloqueRepositoryImpl({BloqueRemoteDatasource? datasource})
      : _datasource = datasource ?? BloqueRemoteDatasource();

  @override
  Future<PagedResult<BloqueResumenEntity>> getBloques({
    String? search,
    String? estado,
    int page = 1,
  }) async {
    final result = await _datasource.getBloques(
      search: search,
      estado: estado,
      page:   page,
    );
    return result.map((m) => m.toEntity());
  }

  @override
  Future<List<BloqueResumenEntity>> getAllBloques({
    String? search,
    String? estado,
  }) async {
    final models = await _datasource.getAllBloques(search: search, estado: estado);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<BloqueDetalleEntity> getBloque(int id) async {
    final model = await _datasource.getBloque(id);
    return model.toEntity();
  }

  @override
  Future<BloqueDetalleEntity> createBloque(
    Map<String, String> fields, {
    XFile? imagen,
  }) async {
    final model = await _datasource.createBloque(fields, imagen: imagen);
    return model.toEntity();
  }

  @override
  Future<BloqueDetalleEntity> updateBloque(
    int id,
    Map<String, String> fields, {
    XFile? imagen,
  }) async {
    final model = await _datasource.updateBloque(id, fields, imagen: imagen);
    return model.toEntity();
  }
}