// lib/features/ficha/domain/repositories/ficha_repository.dart

import '../../../../core/models/paginated_response.dart';
import '../entities/ficha_entity.dart';
import '../../data/models/ficha_request_model.dart';

abstract class FichaRepository {
  Future<PaginatedResponse<FichaListEntity>> getFichas({
    String? search,
    String? etapa,
    String? jornada,
    String? estado,
    bool? cadenaFormacion,
    int? programa,
    int? version,
    int? jefeGrupo,
    String? nivel,
    String? tipoFormacion,
    int page,
    int pageSize,
  });

  Future<FichaEntity> getFicha(int id);

  Future<FichaEntity> createFicha(FichaCreateRequest request);

  Future<FichaEntity> updateFicha(int id, FichaUpdateRequest request);

  Future<FichaEntity> updateEtapa(int id, EtapaUpdateRequest request);

  Future<PaginatedResponse<HistorialEtapaEntity>> getHistorial({
    int? fichaId,
    String? etapaNueva,
    String? etapaAnterior,
    int page,
    int pageSize,
  });
}
