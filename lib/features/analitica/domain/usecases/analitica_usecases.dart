import '../entities/analitica_entities.dart';
import '../repositories/analitica_repository.dart';

class GetDashboardUseCase {
  final AnaliticaRepository _repository;
  const GetDashboardUseCase(this._repository);

  Future<DashboardEntity?> call() => _repository.getDashboard();
}

class GetSnapshotsUseCase {
  final AnaliticaRepository _repository;
  const GetSnapshotsUseCase(this._repository);

  Future<List<AnaliticaSnapshotEntity>> call({
    int limite = 30,
    int? programaId,
  }) =>
      _repository.getSnapshots(limite: limite, programaId: programaId);
}
