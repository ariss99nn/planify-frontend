import '../entities/analitica_entities.dart';

abstract class AnaliticaRepository {
  Future<DashboardEntity?> getDashboard();
  Future<List<AnaliticaSnapshotEntity>> getSnapshots({
    int limite = 30,
    int? programaId,
  });
}
