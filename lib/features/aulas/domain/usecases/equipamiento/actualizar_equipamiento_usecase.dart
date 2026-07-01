// lib/features/aulas/domain/usecases/equipamiento/actualizar_equipamiento_usecase.dart

import 'package:image_picker/image_picker.dart';
import '../../entities/equipamiento_entity.dart';
import '../../repositories/equipamiento_repository.dart';

class ActualizarEquipamientoUseCase {
  final EquipamientoRepository repository;
  const ActualizarEquipamientoUseCase(this.repository);

  Future<EquipamientoDetalleEntity> call(
    int id,
    Map<String, String> fields, {
    XFile? imagen,
  }) =>
      repository.updateEquipamiento(id, fields, imagen: imagen);
}