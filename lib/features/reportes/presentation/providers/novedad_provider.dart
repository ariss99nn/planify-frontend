import 'package:flutter/foundation.dart';

import '../../../../core/api/api_service.dart';
import '../../data/repositories_impl/novedad_repository_impl.dart';
import '../../domain/entities/novedad_entity.dart';
import '../../domain/repositories/novedad_repository.dart';
import '../../domain/usecases/novedad_usecases.dart';

enum NovedadFiltroEstado { todas, pendientes, atendidas }

class NovedadProvider extends ChangeNotifier {
  NovedadProvider({NovedadRepository? repository})
      : _obtenerNovedades =
            ObtenerNovedadesUseCase(repository ?? NovedadRepositoryImpl()),
        _crearNovedad =
            CrearNovedadUseCase(repository ?? NovedadRepositoryImpl()),
        _atenderNovedad =
            AtenderNovedadUseCase(repository ?? NovedadRepositoryImpl());

  final ObtenerNovedadesUseCase _obtenerNovedades;
  final CrearNovedadUseCase _crearNovedad;
  final AtenderNovedadUseCase _atenderNovedad;

  final List<NovedadEntity> _novedades = [];
  List<NovedadEntity> get novedades => List.unmodifiable(_novedades);

  bool _cargando = false;
  bool get cargando => _cargando;

  bool _cargandoMas = false;
  bool get cargandoMas => _cargandoMas;

  String? _error;
  String? get error => _error;

  bool _hayMasPaginas = false;
  int _paginaActual = 1;

  NovedadFiltroEstado _filtroEstado = NovedadFiltroEstado.pendientes;
  NovedadFiltroEstado get filtroEstado => _filtroEstado;

  NovedadTipo? _filtroTipo;
  NovedadTipo? get filtroTipo => _filtroTipo;

  bool _enviando = false;
  bool get enviando => _enviando;

  bool? get _atendidaParaFiltro {
    switch (_filtroEstado) {
      case NovedadFiltroEstado.pendientes:
        return false;
      case NovedadFiltroEstado.atendidas:
        return true;
      case NovedadFiltroEstado.todas:
        return null;
    }
  }

  Future<void> cargarInicial() async {
    _cargando = true;
    _error = null;
    _paginaActual = 1;
    notifyListeners();

    try {
      final pagina = await _obtenerNovedades(
        atendida: _atendidaParaFiltro,
        tipo: _filtroTipo?.value,
        page: _paginaActual,
      );
      _novedades
        ..clear()
        ..addAll(pagina.results);
      _hayMasPaginas = pagina.hasNext;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'No se pudo cargar las novedades.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarMas() async {
    if (_cargandoMas || !_hayMasPaginas) return;
    _cargandoMas = true;
    notifyListeners();

    final paginaSolicitada = _paginaActual + 1;
    try {
      final pagina = await _obtenerNovedades(
        atendida: _atendidaParaFiltro,
        tipo: _filtroTipo?.value,
        page: paginaSolicitada,
      );
      _paginaActual = paginaSolicitada;
      _novedades.addAll(pagina.results);
      _hayMasPaginas = pagina.hasNext;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'No se pudieron cargar más novedades.';
    } finally {
      _cargandoMas = false;
      notifyListeners();
    }
  }

  Future<void> cambiarFiltroEstado(NovedadFiltroEstado nuevo) async {
    if (nuevo == _filtroEstado) return;
    _filtroEstado = nuevo;
    await cargarInicial();
  }

  Future<void> cambiarFiltroTipo(NovedadTipo? nuevo) async {
    if (nuevo == _filtroTipo) return;
    _filtroTipo = nuevo;
    await cargarInicial();
  }

  Future<bool> crear(NovedadCreateInput input) async {
    _enviando = true;
    _error = null;
    notifyListeners();

    try {
      final creada = await _crearNovedad(input);
      if (_atendidaParaFiltro == null || _atendidaParaFiltro == false) {
        _insertarOrdenada(creada);
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'No se pudo crear la novedad.';
      return false;
    } finally {
      _enviando = false;
      notifyListeners();
    }
  }

  Future<bool> atender({
    required int id,
    required String notaAtencion,
  }) async {
    _enviando = true;
    _error = null;
    notifyListeners();

    try {
      final actualizada = await _atenderNovedad(id: id, notaAtencion: notaAtencion);
      final index = _novedades.indexWhere((n) => n.id == id);
      if (index != -1) {
        if (_filtroEstado == NovedadFiltroEstado.pendientes) {
          _novedades.removeAt(index);
        } else {
          _novedades[index] = actualizada;
        }
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'No se pudo marcar la novedad como atendida.';
      return false;
    } finally {
      _enviando = false;
      notifyListeners();
    }
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  void _insertarOrdenada(NovedadEntity novedad) {
    final index = _novedades.indexWhere((n) {
      if (n.prioridad.value != novedad.prioridad.value) {
        return n.prioridad.value > novedad.prioridad.value;
      }
      return n.fechaGeneracion.isBefore(novedad.fechaGeneracion);
    });
    if (index == -1) {
      _novedades.add(novedad);
    } else {
      _novedades.insert(index, novedad);
    }
  }
}
