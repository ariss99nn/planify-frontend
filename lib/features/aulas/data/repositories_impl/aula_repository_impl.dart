// lib/features/aulas/data/repositories_impl/aula_repository_impl.dart

import 'package:image_picker/image_picker.dart';
import '../../domain/entities/aula_entity.dart';
import '../../domain/entities/paged_result.dart';
import '../../domain/repositories/aula_repository.dart';
import '../datasources/aula_remote_datasource.dart';

class AulaRepositoryImpl implements AulaRepository {
  final AulaRemoteDatasource _datasource;
  AulaRepositoryImpl({AulaRemoteDatasource? datasource})
      : _datasource = datasource ?? AulaRemoteDatasource();

  @override
  Future<PagedResult<AulaResumenEntity>> getAulas({
    String? search,
    String? estado,
    String? tipoAula,
    int? bloqueId,
    int page = 1,
  }) async {
    final result = await _datasource.getAulas(
      search:   search,
      estado:   estado,
      tipoAula: tipoAula,
      bloqueId: bloqueId,
      page:     page,
    );
    return result.map((m) => m.toEntity());
  }

  @override
  Future<AulaEntity> getAula(int id) async {
    final model = await _datasource.getAula(id);
    return model.toEntity();
  }

  @override
  Future<AulaEntity> createAula(
    Map<String, String> fields, {
    XFile? imagen,
    List<int> equipamientoIds = const [],
  }) async {
    final model = await _datasource.createAula(
      fields,
      imagen:          imagen,
      equipamientoIds: equipamientoIds,
    );
    return model.toEntity();
  }

  @override
  Future<AulaEntity> updateAula(
    int id,
    Map<String, String> fields, {
    XFile? imagen,
    List<int> equipamientoIds = const [],
  }) async {
    final model = await _datasource.updateAula(
      id,
      fields,
      imagen:          imagen,
      equipamientoIds: equipamientoIds,
    );
    return model.toEntity();
  }

  @override
  Future<void> updateEstado(int id, String estado) =>
      _datasource.updateEstado(id, estado);
}