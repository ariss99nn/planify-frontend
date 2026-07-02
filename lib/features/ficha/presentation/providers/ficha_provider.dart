// lib/features/ficha/presentation/providers/ficha_provider.dart

import 'package:flutter/material.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/widgets/friendly_feedback.dart';
import '../../data/models/ficha_request_model.dart';
import '../../data/repositories_impl/ficha_repository_impl.dart';
import '../../data/repositories_impl/ficha_estudiante_repository_impl.dart';
import '../../data/repositories_impl/reasignacion_repository_impl.dart';
import '../../data/repositories_impl/estudiante_bloqueo_repository_impl.dart';
import '../../domain/entities/ficha_entity.dart';
import '../../domain/entities/estudiante_bloqueo_entity.dart';
import '../../domain/repositories/ficha_repository.dart';
import '../../domain/repositories/ficha_estudiante_repository.dart';
import '../../domain/repositories/reasignacion_repository.dart';
import '../../domain/repositories/estudiante_bloqueo_repository.dart';
import '../../domain/usecases/ficha/listar_fichas_usecase.dart';
import '../../domain/usecases/ficha/obtener_ficha_usecase.dart';
import '../../domain/usecases/ficha/crear_ficha_usecase.dart';
import '../../domain/usecases/ficha/actualizar_ficha_usecase.dart';
import '../../domain/usecases/ficha/actualizar_etapa_usecase.dart';
import '../../domain/usecases/ficha/get_historial_usecase.dart';
import '../../domain/usecases/estudiante/get_estudiantes_usecase.dart';
import '../../domain/usecases/estudiante/add_estudiante_usecase.dart';
import '../../domain/usecases/estudiante/update_estudiante_usecase.dart';
import '../../domain/usecases/reasignacion/get_reasignaciones_usecase.dart';
import '../../domain/usecases/reasignacion/crear_reasignacion_usecase.dart';

class FichaProvider with ChangeNotifier {

  // ── Use cases ──────────────────────────────────────────────────────────────

  late final ListarFichasUseCase        _listarFichas;
  late final ObtenerFichaUseCase        _obtenerFicha;
  late final CrearFichaUseCase          _crearFicha;
  late final ActualizarFichaUseCase     _actualizarFicha;
  late final ActualizarEtapaUseCase     _actualizarEtapa;
  late final GetHistorialUseCase        _getHistorial;
  late final GetEstudiantesUseCase      _getEstudiantes;
  late final AddEstudianteUseCase       _addEstudiante;
  late final UpdateEstudianteUseCase    _updateEstudiante;
  late final GetReasignacionesUseCase   _getReasignaciones;
  late final CrearReasignacionUseCase   _crearReasignacion;
  late final EstudianteBloqueoRepository _bloqueoRepo;

  FichaProvider({
    FichaRepository?             fichaRepo,
    FichaEstudianteRepository?   estudianteRepo,
    ReasignacionRepository?      reasignacionRepo,
    EstudianteBloqueoRepository? bloqueoRepo,
  }) {
    final fr = fichaRepo          ?? FichaRepositoryImpl();
    final er = estudianteRepo     ?? FichaEstudianteRepositoryImpl();
    final rr = reasignacionRepo   ?? ReasignacionRepositoryImpl();
    _bloqueoRepo = bloqueoRepo    ?? EstudianteBloqueoRepositoryImpl();

    _listarFichas      = ListarFichasUseCase(fr);
    _obtenerFicha      = ObtenerFichaUseCase(fr);
    _crearFicha        = CrearFichaUseCase(fr);
    _actualizarFicha   = ActualizarFichaUseCase(fr);
    _actualizarEtapa   = ActualizarEtapaUseCase(fr);
    _getHistorial      = GetHistorialUseCase(fr);
    _getEstudiantes    = GetEstudiantesUseCase(er);
    _addEstudiante     = AddEstudianteUseCase(er);
    _updateEstudiante  = UpdateEstudianteUseCase(er);
    _getReasignaciones = GetReasignacionesUseCase(rr);
    _crearReasignacion = CrearReasignacionUseCase(rr);
  }

  // ── Estado — listado ───────────────────────────────────────────────────────

  List<FichaListEntity> fichas = [];
  bool     loadingFichas  = false;
  String?  fichasError;
  int      totalFichas    = 0;
  int      paginaActual   = 1;
  bool     hayMasPaginas  = false;

  // ── Estado — detalle ───────────────────────────────────────────────────────

  FichaEntity? fichaDetalle;
  bool     loadingDetalle = false;
  String?  detalleError;

  // ── Estado — historial ─────────────────────────────────────────────────────

  List<HistorialEtapaEntity> historial = [];
  bool    loadingHistorial       = false;
  String? historialError;
  int     totalHistorial         = 0;
  int     paginaActualHistorial  = 1;
  bool    hayMasPaginasHistorial = false;

  // ── Estado — estudiantes ───────────────────────────────────────────────────

  List<FichaEstudianteEntity> estudiantes = [];
  bool    loadingEstudiantes = false;
  String? estudiantesError;
  int     totalEstudiantes   = 0;

  // ── Estado — reasignaciones ────────────────────────────────────────────────

  List<ReasignacionEntity> reasignaciones = [];
  bool    loadingReasignaciones       = false;
  String? reasignacionesError;
  int     totalReasignaciones         = 0;
  int     paginaActualReasignaciones  = 1;
  bool    hayMasPaginasReasignaciones = false;

  // ── Estado — mutaciones ────────────────────────────────────────────────────

  bool    loadingMutation = false;
  String? mutationError;

  // ── Filtros activos ────────────────────────────────────────────────────────

  String? filtroSearch;
  String? filtroEtapa;
  String? filtroJornada;
  String? filtroEstado;
  bool?   filtroCadena;
  String? filtroNivel;
  String? filtroTipoFormacion;

  // ── Fichas — GET list ──────────────────────────────────────────────────────

  Future<void> fetchFichas({
    String? search,
    String? etapa,
    String? jornada,
    String? estado,
    bool?   cadenaFormacion,
    int?    programa,
    int?    version,
    int?    jefeGrupo,
    String? nivel,
    String? tipoFormacion,
    int     page   = 1,
    bool    append = false,
  }) async {
    if (!append) {
      filtroSearch        = search;
      filtroEtapa         = etapa;
      filtroJornada       = jornada;
      filtroEstado        = estado;
      filtroCadena        = cadenaFormacion;
      filtroNivel         = nivel;
      filtroTipoFormacion = tipoFormacion;
      paginaActual        = 1;
      fichasError         = null;
    }

    loadingFichas = true;
    notifyListeners();

    try {
      final PaginatedResponse<FichaListEntity> res = await _listarFichas(
        search:          search          ?? filtroSearch,
        etapa:           etapa           ?? filtroEtapa,
        jornada:         jornada         ?? filtroJornada,
        estado:          estado          ?? filtroEstado,
        cadenaFormacion: cadenaFormacion ?? filtroCadena,
        programa:        programa,
        version:         version,
        jefeGrupo:       jefeGrupo,
        nivel:           nivel           ?? filtroNivel,
        tipoFormacion:   tipoFormacion   ?? filtroTipoFormacion,
        page:            page,
      );

      if (append) {
        fichas.addAll(res.results);
      } else {
        fichas = res.results;
      }
      totalFichas   = res.count;
      hayMasPaginas = res.hasMore;
      paginaActual  = page;
      fichasError   = null;
    } catch (e) {
      fichasError = friendlyErrorMessage(e);
      if (!append) fichas = [];
    } finally {
      loadingFichas = false;
      notifyListeners();
    }
  }

  Future<void> fetchMasFichas() async {
    if (!hayMasPaginas || loadingFichas) return;
    await fetchFichas(page: paginaActual + 1, append: true);
  }

  // ── Fichas — GET detalle ───────────────────────────────────────────────────

  Future<void> fetchDetalle(int id) async {
    loadingDetalle = true;
    fichaDetalle   = null;
    detalleError   = null;
    notifyListeners();

    try {
      fichaDetalle = await _obtenerFicha(id);
    } catch (e) {
      detalleError = friendlyErrorMessage(e);
    } finally {
      loadingDetalle = false;
      notifyListeners();
    }
  }

  // ── Fichas — POST create ───────────────────────────────────────────────────

  Future<FichaEntity?> createFicha(FichaCreateRequest request) async {
    _startMutation();
    try {
      final ficha = await _crearFicha(request);
      await fetchFichas();
      return ficha;
    } catch (e) {
      mutationError = friendlyErrorMessage(e);
      notifyListeners();
      return null;
    } finally {
      _endMutation();
    }
  }

  // ── Fichas — PATCH update ──────────────────────────────────────────────────

  Future<FichaEntity?> updateFicha(int id, FichaUpdateRequest request) async {
    _startMutation();
    try {
      final ficha = await _actualizarFicha(id, request);
      if (fichaDetalle?.id == id) fichaDetalle = ficha;
      _patchListItem(id, ficha);
      return ficha;
    } catch (e) {
      mutationError = friendlyErrorMessage(e);
      notifyListeners();
      return null;
    } finally {
      _endMutation();
    }
  }

  // ── Fichas — PATCH etapa ───────────────────────────────────────────────────

  Future<FichaEntity?> updateEtapa(int id, EtapaUpdateRequest request) async {
    _startMutation();
    try {
      final ficha = await _actualizarEtapa(id, request);
      if (fichaDetalle?.id == id) fichaDetalle = ficha;
      return ficha;
    } catch (e) {
      mutationError = friendlyErrorMessage(e);
      notifyListeners();
      return null;
    } finally {
      _endMutation();
    }
  }

  // ── Historial ──────────────────────────────────────────────────────────────

  Future<void> fetchHistorial({
    int?    fichaId,
    String? etapaNueva,
    String? etapaAnterior,
    int     page   = 1,
    bool    append = false,
  }) async {
    loadingHistorial = true;
    if (!append) historialError = null;
    notifyListeners();

    try {
      final res = await _getHistorial(
        fichaId:       fichaId,
        etapaNueva:    etapaNueva,
        etapaAnterior: etapaAnterior,
        page:          page,
      );
      if (append) {
        historial.addAll(res.results);
      } else {
        historial = res.results;
      }
      totalHistorial         = res.count;
      hayMasPaginasHistorial = res.hasMore;
      paginaActualHistorial  = page;
    } catch (e) {
      historialError = friendlyErrorMessage(e);
      if (!append) historial = [];
    } finally {
      loadingHistorial = false;
      notifyListeners();
    }
  }

  Future<void> fetchMasHistorial() async {
    if (!hayMasPaginasHistorial || loadingHistorial) return;
    await fetchHistorial(page: paginaActualHistorial + 1, append: true);
  }

  // ── Estudiantes — GET ──────────────────────────────────────────────────────

  Future<void> fetchEstudiantes(
    int fichaId, {
    bool?   activo,
    bool?   esCadena,
    String? motivoRetiro,
    int     page     = 1,
    int     pageSize = 50,
  }) async {
    loadingEstudiantes = true;
    estudiantesError   = null;
    notifyListeners();

    try {
      final res = await _getEstudiantes(
        fichaId,
        activo:       activo,
        esCadena:     esCadena,
        motivoRetiro: motivoRetiro,
        page:         page,
        pageSize:     pageSize,
      );
      estudiantes      = res.results;
      totalEstudiantes = res.count;
    } catch (e) {
      estudiantesError = friendlyErrorMessage(e);
      estudiantes      = [];
    } finally {
      loadingEstudiantes = false;
      notifyListeners();
    }
  }

  // ── Estudiantes — POST add ─────────────────────────────────────────────────

  Future<FichaEstudianteEntity?> addEstudiante(
    int fichaId,
    AddEstudianteRequest request,
  ) async {
    _startMutation();
    try {
      final rel = await _addEstudiante(fichaId, request);
      estudiantes = [rel, ...estudiantes];
      totalEstudiantes++;
      return rel;
    } catch (e) {
      mutationError = friendlyErrorMessage(e);
      notifyListeners();
      return null;
    } finally {
      _endMutation();
    }
  }

  // ── Estudiantes — PATCH update ─────────────────────────────────────────────

  Future<FichaEstudianteEntity?> updateEstudiante(
    int fichaId,
    int relacionId,
    UpdateEstudianteRequest request,
  ) async {
    _startMutation();
    try {
      final rel = await _updateEstudiante(fichaId, relacionId, request);
      final idx = estudiantes.indexWhere((e) => e.id == relacionId);
      if (idx != -1) estudiantes[idx] = rel;
      return rel;
    } catch (e) {
      mutationError = friendlyErrorMessage(e);
      notifyListeners();
      return null;
    } finally {
      _endMutation();
    }
  }

  // ── Reasignaciones — GET ───────────────────────────────────────────────────

  Future<void> fetchReasignaciones({
    int? estudianteId,
    int? fichaOrigenId,
    int? fichaDestinoId,
    int  page   = 1,
    bool append = false,
  }) async {
    loadingReasignaciones = true;
    if (!append) reasignacionesError = null;
    notifyListeners();

    try {
      final res = await _getReasignaciones(
        estudianteId:   estudianteId,
        fichaOrigenId:  fichaOrigenId,
        fichaDestinoId: fichaDestinoId,
        page:           page,
      );
      if (append) {
        reasignaciones.addAll(res.results);
      } else {
        reasignaciones = res.results;
      }
      totalReasignaciones         = res.count;
      hayMasPaginasReasignaciones = res.hasMore;
      paginaActualReasignaciones  = page;
    } catch (e) {
      reasignacionesError = friendlyErrorMessage(e);
      if (!append) reasignaciones = [];
    } finally {
      loadingReasignaciones = false;
      notifyListeners();
    }
  }

  Future<void> fetchMasReasignaciones() async {
    if (!hayMasPaginasReasignaciones || loadingReasignaciones) return;
    await fetchReasignaciones(
        page: paginaActualReasignaciones + 1, append: true);
  }

  // ── Reasignaciones — POST create ───────────────────────────────────────────

  Future<ReasignacionEntity?> createReasignacion(
    ReasignacionCreateRequest request,
  ) async {
    _startMutation();
    try {
      final r = await _crearReasignacion(request);
      reasignaciones = [r, ...reasignaciones];
      totalReasignaciones++;
      return r;
    } catch (e) {
      mutationError = friendlyErrorMessage(e);
      notifyListeners();
      return null;
    } finally {
      _endMutation();
    }
  }

  // ── Estudiantes bloqueados ──────────────────────────────────────────────────

  List<EstudianteBloqueoEntity> bloqueos = [];
  bool    loadingBloqueos = false;
  String? bloqueosError;

  Future<void> fetchBloqueos({bool soloActivos = true}) async {
    loadingBloqueos = true;
    bloqueosError    = null;
    notifyListeners();
    try {
      final res = await _bloqueoRepo.listar(activo: soloActivos ? true : null);
      bloqueos = res.results;
    } catch (e) {
      bloqueosError = friendlyErrorMessage(e);
      bloqueos = [];
    } finally {
      loadingBloqueos = false;
      notifyListeners();
    }
  }

  Future<bool> desbloquearEstudiante(int bloqueoId, {String observacion = ''}) async {
    _startMutation();
    try {
      final actualizado = await _bloqueoRepo.desbloquear(
        bloqueoId,
        observacion: observacion,
      );
      bloqueos = bloqueos.where((b) => b.id != actualizado.id).toList();
      return true;
    } catch (e) {
      mutationError = friendlyErrorMessage(e);
      notifyListeners();
      return false;
    } finally {
      _endMutation();
    }
  }

  // ── Helpers de limpieza ────────────────────────────────────────────────────

  void limpiarDetalle() {
    fichaDetalle   = null;
    detalleError   = null;
    estudiantes    = [];
    reasignaciones = [];
    historial      = [];
    notifyListeners();
  }

  void limpiarFiltros() {
    filtroSearch  = null;
    filtroEtapa   = null;
    filtroJornada = null;
    filtroEstado  = null;
    filtroCadena  = null;
    notifyListeners();
  }

  void limpiarMutationError() {
    mutationError = null;
    notifyListeners();
  }

  // ── Internos ───────────────────────────────────────────────────────────────

  void _startMutation() {
    loadingMutation = true;
    mutationError   = null;
    notifyListeners();
  }

  void _endMutation() {
    loadingMutation = false;
    notifyListeners();
  }

  void _patchListItem(int id, FichaEntity ficha) {
    final idx = fichas.indexWhere((f) => f.id == id);
    if (idx == -1) return;
    fichas[idx] = FichaListEntity(
      id:                        ficha.id,
      codigoFicha:               ficha.codigoFicha,
      programaNombre:            ficha.programaNombre,
      versionNumero:             ficha.versionNumero,
      jornada:                   ficha.jornada,
      jornadaDisplay:            ficha.jornadaDisplay,
      etapa:                     ficha.etapa,
      etapaDisplay:              ficha.etapaDisplay,
      trimestre:                 ficha.trimestre,
      estado:                    ficha.estado,
      cadenaFormacion:           ficha.cadenaFormacion,
      numeroEstudiantesEstimado: ficha.numeroEstudiantesEstimado,
      numeroEstudiantesReal:     ficha.numeroEstudiantesReal,
      jefeGrupoNombre:           ficha.jefeGrupoNombre,
      fechaInicio:               ficha.fechaInicio,
      fechaFinalizacion:         ficha.fechaFinalizacion,
    );
  }
}
