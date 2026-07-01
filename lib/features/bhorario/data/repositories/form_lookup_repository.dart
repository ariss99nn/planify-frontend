// lib/features/bhorario/data/repositories/form_lookup_repository.dart
//
// NOTA sobre rutas:
// Las rutas se infieren del urls.py de cada app.
// La de competencias DEBE confirmarse con el include() del urls.py raíz:
//
//   Si el include es:  path('competencia/', include('competencia.urls'))
//   → la ruta es:     /competencia/competencias/   ← ASUMIDA AQUÍ
//
//   Si el include es:  path('', include('competencia.urls'))
//   → la ruta es:     /competencias/
//
// Ajusta _kCompetenciasPath según corresponda.

import '../../../../core/api/api_service.dart';
import '../models/fk_option_model.dart';

const _kCompetenciasPath = '/competencias/competencias/';

class FormLookupRepository {

  static Future<List<FkOption>> getAulas({required String token}) async {
    final raw = await ApiService.get('/aulas/', token: token);
    return _parse(raw, FkOption.fromAulaJson);
  }

  static Future<List<FkOption>> getDocentes({required String token}) async {
    final raw = await ApiService.get('/docentes/', token: token);
    return _parse(raw, FkOption.fromDocenteJson);
  }

  static Future<List<FkOption>> getFichas({required String token}) async {
    final raw = await ApiService.get('/fichas/', token: token);
    return _parse(raw, FkOption.fromFichaJson);
  }

  static Future<List<FkOption>> getCompetencias({required String token}) async {
    final raw = await ApiService.get(_kCompetenciasPath, token: token);
    return _parse(raw, FkOption.fromCompetenciaJson);
  }

  /// Normaliza respuesta plana [ ] o paginada {count, results:[]} a List<FkOption>.
  static List<FkOption> _parse(
    dynamic raw,
    FkOption Function(Map<String, dynamic>) factory,
  ) {
    List<dynamic> items;
    if (raw is List) {
      items = raw;
    } else if (raw is Map && raw.containsKey('results')) {
      items = raw['results'] as List<dynamic>;
    } else {
      return [];
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(factory)
        .toList();
  }
}