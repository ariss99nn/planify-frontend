// lib/features/aulas/domain/usecases/bloque/actualizar_bloque_usecase.dart

import 'package:image_picker/image_picker.dart';
import '../../entities/bloque_entity.dart';
import '../../repositories/bloque_repository.dart';

class ActualizarBloqueUseCase {
  final BloqueRepository repository;
  const ActualizarBloqueUseCase(this.repository);

  Future<BloqueDetalleEntity> call(
    int id,
    Map<String, String> fields, {
    XFile? imagen,
  }) =>
      repository.updateBloque(id, fields, imagen: imagen);
}