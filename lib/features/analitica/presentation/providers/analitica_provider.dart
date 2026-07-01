import 'package:flutter/foundation.dart';

import '../../domain/entities/analitica_entities.dart';
import '../../domain/usecases/analitica_usecases.dart';

class AnaliticaProvider extends ChangeNotifier {
  final GetDashboardUseCase  _getDashboard;
  final GetSnapshotsUseCase  _getSnapshots;

  AnaliticaProvider({
    required GetDashboardUseCase  getDashboard,
    required GetSnapshotsUseCase  getSnapshots,
  })  : _getDashboard = getDashboard,
        _getSnapshots = getSnapshots;

  // ── Dashboard state ──────────────────────────────────────────────────────
  DashboardEntity? dashboard;
  bool    dashboardLoading  = false;
  String? dashboardError;
  bool    sinSnapshot       = false;

  Future<void> cargarDashboard() async {
    dashboardLoading = true;
    dashboardError   = null;
    sinSnapshot      = false;
    notifyListeners();
    try {
      final data = await _getDashboard();
      dashboard   = data;
      sinSnapshot = data == null;
    } catch (e) {
      dashboardError = e.toString();
    } finally {
      dashboardLoading = false;
      notifyListeners();
    }
  }

  // ── Snapshots state ───────────────────────────────────────────────────────
  List<AnaliticaSnapshotEntity> snapshots = [];
  bool    snapshotsLoading = false;
  String? snapshotsError;

  Future<void> cargarSnapshots({int limite = 30}) async {
    snapshotsLoading = true;
    snapshotsError   = null;
    notifyListeners();
    try {
      snapshots = await _getSnapshots(limite: limite);
    } catch (e) {
      snapshotsError = e.toString();
    } finally {
      snapshotsLoading = false;
      notifyListeners();
    }
  }
}
