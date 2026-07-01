import '../../domain/entities/analitica_entities.dart';
import '../../domain/repositories/analitica_repository.dart';
import '../datasources/analitica_remote_datasource.dart';

class AnaliticaRepositoryImpl implements AnaliticaRepository {
  final AnaliticaRemoteDataSource _dataSource;
  const AnaliticaRepositoryImpl(this._dataSource);

  @override
  Future<DashboardEntity?> getDashboard() async {
    final model = await _dataSource.getDashboard();
    return model?.toEntity();
  }

  @override
  Future<List<AnaliticaSnapshotEntity>> getSnapshots({
    int limite = 30,
    int? programaId,
  }) async {
    final models = await _dataSource.getSnapshots(
      limite:     limite,
      programaId: programaId,
    );
    return models.map((m) => m.toEntity()).toList();
  }
}
