import '../../../../core/api/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/analitica_model.dart';

abstract class AnaliticaRemoteDataSource {
  Future<DashboardModel?> getDashboard();
  Future<List<AnaliticaSnapshotModel>> getSnapshots({
    int limite = 30,
    int? programaId,
  });
}

class AnaliticaRemoteDataSourceImpl implements AnaliticaRemoteDataSource {
  static const _base = '/analitica';

  @override
  Future<DashboardModel?> getDashboard() async {
    final token = await TokenStorage.getAccessToken();
    final data  = await ApiService.get('$_base/', token: token);
    final map   = data as Map<String, dynamic>;
    if (map.containsKey('mensaje')) return null;
    return DashboardModel.fromJson(map);
  }

  @override
  Future<List<AnaliticaSnapshotModel>> getSnapshots({
    int limite = 30,
    int? programaId,
  }) async {
    final token  = await TokenStorage.getAccessToken();
    final params = <String, String>{
      'limite': limite.toString(),
      if (programaId != null) 'programa': programaId.toString(),
    };
    final data = await ApiService.get(
      '$_base/snapshots/',
      token:       token,
      queryParams: params,
    );
    return (data as List<dynamic>)
        .map((e) => AnaliticaSnapshotModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
