// lib/features/aulas/domain/repositories/aula_repository.dart

import 'package:image_picker/image_picker.dart';
import '../entities/aula_entity.dart';
import '../entities/paged_result.dart';

abstract class AulaRepository {
  Future<PagedResult<AulaResumenEntity>> getAulas({
    String? search,
    String? estado,
    String? tipoAula,
    int? bloqueId,
    int page = 1,
  });

  Future<AulaEntity> getAula(int id);

  Future<AulaEntity> createAula(
    Map<String, String> fields, {
    XFile? imagen,
    List<int> equipamientoIds,
  });

  Future<AulaEntity> updateAula(
    int id,
    Map<String, String> fields, {
    XFile? imagen,
    List<int> equipamientoIds,
  });

  Future<void> updateEstado(int id, String estado);
}