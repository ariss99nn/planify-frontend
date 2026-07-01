// lib/features/aulas/domain/usecases/aula/crear_aula_usecase.dart

import 'package:image_picker/image_picker.dart';
import '../../entities/aula_entity.dart';
import '../../repositories/aula_repository.dart';

class CrearAulaUseCase {
  final AulaRepository repository;
  const CrearAulaUseCase(this.repository);

  Future<AulaEntity> call(
    Map<String, String> fields, {
    XFile? imagen,
    List<int> equipamientoIds = const [],
  }) =>
      repository.createAula(fields, imagen: imagen, equipamientoIds: equipamientoIds);
}