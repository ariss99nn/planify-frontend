// lib/features/aulas/data/repositories_impl/equipamiento_repository_impl.dart

import 'package:image_picker/image_picker.dart';
import '../../domain/entities/equipamiento_entity.dart';
import '../../domain/entities/paged_result.dart';
import '../../domain/repositories/equipamiento_repository.dart';
import '../datasources/equipamiento_remote_datasource.dart';

class EquipamientoRepositoryImpl implements EquipamientoRepository {
  final EquipamientoRemoteDatasource _datasource;
  EquipamientoRepositoryImpl({EquipamientoRemoteDatasource? datasource})
      : _datasource = datasource ?? EquipamientoRemoteDatasource();

  @override
  Future<PagedResult<EquipamientoResumenEntity>> getEquipamientos({
    String? search,
    String? estado,
    int page = 1,
  }) async {
    final result = await _datasource.getEquipamientos(
      search: search,
      estado: estado,
      page:   page,
    );
    return result.map((m) => m.toEntity());
  }

  @override
  Future<List<EquipamientoResumenEntity>> getAllEquipamientos({
    String? search,
    String? estado,
  }) async {
    final models = await _datasource.getAllEquipamientos(search: search, estado: estado);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<EquipamientoDetalleEntity> getEquipamiento(int id) async {
    final model = await _datasource.getEquipamiento(id);
    return model.toEntity();
  }

  @override
  Future<EquipamientoDetalleEntity> createEquipamiento(
    Map<String, String> fields, {
    XFile? imagen,
  }) async {
    final model = await _datasource.createEquipamiento(fields, imagen: imagen);
    return model.toEntity();
  }

  @override
  Future<EquipamientoDetalleEntity> updateEquipamiento(
    int id,
    Map<String, String> fields, {
    XFile? imagen,
  }) async {
    final model = await _datasource.updateEquipamiento(id, fields, imagen: imagen);
    return model.toEntity();
  }
}