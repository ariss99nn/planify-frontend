// lib/features/ficha/domain/usecases/ficha/actualizar_etapa_usecase.dart

import '../../entities/ficha_entity.dart';
import '../../repositories/ficha_repository.dart';
import '../../../data/models/ficha_request_model.dart';

class ActualizarEtapaUseCase {
  final FichaRepository repository;
  const ActualizarEtapaUseCase(this.repository);

  Future<FichaEntity> call(int id, EtapaUpdateRequest request) =>
      repository.updateEtapa(id, request);
}
