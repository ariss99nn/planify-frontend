// lib/features/ficha/data/repositories_impl/ficha_repository_impl.dart

import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/ficha_entity.dart';
import '../../domain/repositories/ficha_repository.dart';
import '../../data/models/ficha_request_model.dart';
import '../datasources/ficha_remote_datasource.dart';

class FichaRepositoryImpl implements FichaRepository {
  final FichaRemoteDatasource _datasource;

  FichaRepositoryImpl({FichaRemoteDatasource? datasource})
      : _datasource = datasource ?? FichaRemoteDatasource();

  @override
  Future<PaginatedResponse<FichaListEntity>> getFichas({
    String? search,
    String? etapa,
    String? jornada,
    String? estado,
    bool? cadenaFormacion,
    int? programa,
    int? version,
    int? jefeGrupo,
    int page     = 1,
    int pageSize = 20,
  }) async {
    final r = await _datasource.getFichas(
      search: search, etapa: etapa, jornada: jornada, estado: estado,
      cadenaFormacion: cadenaFormacion, programa: programa,
      version: version, jefeGrupo: jefeGrupo, page: page, pageSize: pageSize,
    );
    return PaginatedResponse<FichaListEntity>(
      count:    r.count,
      next:     r.next,
      previous: r.previous,
      results:  r.results.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<FichaEntity> getFicha(int id) async {
    final model = await _datasource.getFicha(id);
    return model.toEntity();
  }

  @override
  Future<FichaEntity> createFicha(FichaCreateRequest request) async {
    final model = await _datasource.createFicha(request.toJson());
    return model.toEntity();
  }

  @override
  Future<FichaEntity> updateFicha(int id, FichaUpdateRequest request) async {
    final model = await _datasource.updateFicha(id, request.toJson());
    return model.toEntity();
  }

  @override
  Future<FichaEntity> updateEtapa(int id, EtapaUpdateRequest request) async {
    final model = await _datasource.updateEtapa(
      id,
      etapa: request.etapa,
    );
    return model.toEntity();
  }

  @override
  Future<PaginatedResponse<HistorialEtapaEntity>> getHistorial({
    int? fichaId,
    String? etapaNueva,
    String? etapaAnterior,
    int page     = 1,
    int pageSize = 20,
  }) async {
    final r = await _datasource.getHistorial(
      fichaId:       fichaId,
      etapaNueva:    etapaNueva,
      etapaAnterior: etapaAnterior,
      page:          page,
      pageSize:      pageSize,
    );
    return PaginatedResponse<HistorialEtapaEntity>(
      count:    r.count,
      next:     r.next,
      previous: r.previous,
      results:  r.results.map((m) => m.toEntity()).toList(),
    );
  }
}
