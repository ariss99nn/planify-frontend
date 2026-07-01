// lib/features/aulas/domain/repositories/bloque_repository.dart

import 'package:image_picker/image_picker.dart';
import '../entities/bloque_entity.dart';
import '../entities/paged_result.dart';

abstract class BloqueRepository {
  Future<PagedResult<BloqueResumenEntity>> getBloques({
    String? search,
    String? estado,
    int page = 1,
  });

  /// Catálogo completo (todas las páginas) — para selectores/dropdowns.
  Future<List<BloqueResumenEntity>> getAllBloques({
    String? search,
    String? estado,
  });

  Future<BloqueDetalleEntity> getBloque(int id);

  Future<BloqueDetalleEntity> createBloque(
    Map<String, String> fields, {
    XFile? imagen,
  });

  Future<BloqueDetalleEntity> updateBloque(
    int id,
    Map<String, String> fields, {
    XFile? imagen,
  });
}