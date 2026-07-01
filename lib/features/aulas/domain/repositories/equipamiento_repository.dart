// lib/features/aulas/domain/repositories/equipamiento_repository.dart

import 'package:image_picker/image_picker.dart';
import '../entities/equipamiento_entity.dart';
import '../entities/paged_result.dart';

abstract class EquipamientoRepository {
  Future<PagedResult<EquipamientoResumenEntity>> getEquipamientos({
    String? search,
    String? estado,
    int page = 1,
  });

  /// Catálogo completo (todas las páginas) — para el multi-select de aula.
  Future<List<EquipamientoResumenEntity>> getAllEquipamientos({
    String? search,
    String? estado,
  });

  Future<EquipamientoDetalleEntity> getEquipamiento(int id);

  Future<EquipamientoDetalleEntity> createEquipamiento(
    Map<String, String> fields, {
    XFile? imagen,
  });

  Future<EquipamientoDetalleEntity> updateEquipamiento(
    int id,
    Map<String, String> fields, {
    XFile? imagen,
  });
}