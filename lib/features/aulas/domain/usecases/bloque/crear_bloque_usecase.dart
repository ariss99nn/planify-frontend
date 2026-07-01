// lib/features/aulas/domain/usecases/bloque/crear_bloque_usecase.dart

import 'package:image_picker/image_picker.dart';
import '../../entities/bloque_entity.dart';
import '../../repositories/bloque_repository.dart';

class CrearBloqueUseCase {
  final BloqueRepository repository;
  const CrearBloqueUseCase(this.repository);

  Future<BloqueDetalleEntity> call(Map<String, String> fields, {XFile? imagen}) =>
      repository.createBloque(fields, imagen: imagen);
}