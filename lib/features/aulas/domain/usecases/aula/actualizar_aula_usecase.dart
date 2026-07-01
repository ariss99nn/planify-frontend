// lib/features/aulas/domain/usecases/aula/actualizar_aula_usecase.dart

import 'package:image_picker/image_picker.dart';
import '../../entities/aula_entity.dart';
import '../../repositories/aula_repository.dart';

class ActualizarAulaUseCase {
  final AulaRepository repository;
  const ActualizarAulaUseCase(this.repository);

  Future<AulaEntity> call(
    int id,
    Map<String, String> fields, {
    XFile? imagen,
    List<int> equipamientoIds = const [],
  }) =>
      repository.updateAula(id, fields, imagen: imagen, equipamientoIds: equipamientoIds);
}