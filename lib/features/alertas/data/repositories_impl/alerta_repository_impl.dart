import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/alerta_entity.dart';
import '../../domain/repositories/alerta_repository.dart';
import '../datasources/alerta_remote_datasource.dart';

class AlertaRepositoryImpl implements AlertaRepository {
  final AlertaRemoteDatasource _remote;

  const AlertaRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, AlertaPage>> listar(AlertaFiltros filtros) async {
    try {
      final dto = await _remote.listar(
        tipo: filtros.tipo,
        estado: filtros.estado,
        soloNoLeidas: filtros.soloNoLeidas,
        page: filtros.page,
        pageSize: filtros.pageSize,
      );
      return Right(
        AlertaPage(
          items: dto.items.map((m) => m.toEntity()).toList(),
          count: dto.count,
          hasMore: dto.hasMore,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('Sin conexión a Internet.'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AlertaEntity>> marcarLeida(int alertaId) async {
    try {
      final model = await _remote.marcarLeida(alertaId);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('Sin conexión a Internet.'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AlertaEntity>> crear({
    required String tipo,
    required String descripcion,
    required String formatoAlerta,
    int? destinatario,
    int? bloqueOrigen,
  }) async {
    try {
      final model = await _remote.crear(
        tipo: tipo,
        descripcion: descripcion,
        formatoAlerta: formatoAlerta,
        destinatario: destinatario,
        bloqueOrigen: bloqueOrigen,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('Sin conexión a Internet.'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AlertaEntity>>> crearPorRol({
    required String tipo,
    required String descripcion,
    required String formatoAlerta,
    required String destinatarioRol,
    int? bloqueOrigen,
  }) async {
    try {
      final models = await _remote.crearPorRol(
        tipo: tipo,
        descripcion: descripcion,
        formatoAlerta: formatoAlerta,
        destinatarioRol: destinatarioRol,
        bloqueOrigen: bloqueOrigen,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('Sin conexión a Internet.'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
