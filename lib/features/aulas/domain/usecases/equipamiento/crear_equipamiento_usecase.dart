// lib/features/aulas/domain/usecases/equipamiento/crear_equipamiento_usecase.dart

import 'package:image_picker/image_picker.dart';
import '../../entities/equipamiento_entity.dart';
import '../../repositories/equipamiento_repository.dart';

class CrearEquipamientoUseCase {
  final EquipamientoRepository repository;
  const CrearEquipamientoUseCase(this.repository);

  Future<EquipamientoDetalleEntity> call(
    Map<String, String> fields, {
    XFile? imagen,
  }) =>
      repository.createEquipamiento(fields, imagen: imagen);
}