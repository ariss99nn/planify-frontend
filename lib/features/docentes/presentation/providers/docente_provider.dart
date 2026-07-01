// lib/features/docentes/presentation/providers/docente_provider.dart

import 'package:flutter/material.dart';
import '../../domain/entities/docente_entity.dart';
import '../../domain/entities/disponibilidad_entity.dart';
import '../../domain/entities/habilitacion_entity.dart';
import '../../domain/usecases/docente_usecases.dart';
import '../../data/repositories_impl/docente_repository_impl.dart';

class DocenteProvider with ChangeNotifier {
  final _repo = DocenteRepositoryImpl();

  late final _getDocentes         = GetDocentesUseCase(_repo);
  late final _getDocente          = GetDocenteUseCase(_repo);
  late final _createDocente       = CreateDocenteUseCase(_repo);
  late final _updateDocente       = UpdateDocenteUseCase(_repo);
  late final _deactivateDocente   = DeactivateDocenteUseCase(_repo);
  late final _getDisponibilidad   = GetDisponibilidadUseCase(_repo);
  late final _createDisponibilidad = CreateDisponibilidadUseCase(_repo);
  late final _updateDisponibilidad = UpdateDisponibilidadUseCase(_repo);
  late final _deleteDisponibilidad = DeleteDisponibilidadUseCase(_repo);
  late final _getHabilitaciones   = GetHabilitacionesUseCase(_repo);
  late final _createHabilitacion  = CreateHabilitacionUseCase(_repo);
  late final _updateHabilitacion  = UpdateHabilitacionUseCase(_repo);

  // ── Estado docentes ───────────────────────────────────────────────────────

  List<DocenteEntity> docentes    = [];
  bool                loading     = false;
  String?             error;
  int                 totalCount  = 0;
  int                 currentPage = 1;
  bool                hasNextPage = false;

  // ── Estado disponibilidad ─────────────────────────────────────────────────

  List<DisponibilidadEntity> disponibilidades      = [];
  bool                       loadingDisponibilidad = false;
  String?                    errorDisponibilidad;

  // ── Estado habilitaciones ─────────────────────────────────────────────────

  List<HabilitacionEntity> habilitaciones        = [];
  bool                     loadingHabilitaciones = false;
  String?                  errorHabilitaciones;
  int                      habilitacionesTotal   = 0;
  int                      habilitacionesPage    = 1;

  // ── Docentes ──────────────────────────────────────────────────────────────

  Future<void> fetchDocentes({
    String? search,
    bool?   estado,
    String? especialidad,
    int     page = 1,
  }) async {
    loading = true;
    error   = null;
    notifyListeners();
    try {
      final result = await _getDocentes(
        search: search, estado: estado, especialidad: especialidad, page: page,
      );
      docentes    = result.results;
      totalCount  = result.count;
      hasNextPage = result.hasNext;
      currentPage = page;
    } catch (e) {
      docentes = [];
      error    = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<DocenteEntity?> fetchDocente(int id) async {
    try {
      return await _getDocente(id);
    } catch (_) {
      return null;
    }
  }

  Future<void> createDocente({
    required int    userId,
    required String especialidad,
    required int    horasMaxSemanales,
    bool            estado                = true,
    bool            permiteHorasExtra     = false,
    int             horasExtraAutorizadas = 0,
    dynamic         imagen,
  }) =>
      _createDocente(
        userId:               userId,
        especialidad:         especialidad,
        horasMaxSemanales:    horasMaxSemanales,
        estado:               estado,
        permiteHorasExtra:    permiteHorasExtra,
        horasExtraAutorizadas: horasExtraAutorizadas,
        imagen:               imagen,
      );

  Future<void> updateDocente({
    required int                  id,
    required Map<String, dynamic> data,
    dynamic                       imagen,
    bool                          eliminarImagen = false,
  }) =>
      _updateDocente(
        id: id, data: data, imagen: imagen, eliminarImagen: eliminarImagen,
      );

  Future<void> deactivateDocente(int id) => _deactivateDocente(id);

  // ── Disponibilidad ────────────────────────────────────────────────────────

  Future<void> fetchDisponibilidad(int docenteId) async {
    loadingDisponibilidad = true;
    errorDisponibilidad   = null;
    notifyListeners();
    try {
      disponibilidades = await _getDisponibilidad(docenteId);
    } catch (e) {
      disponibilidades    = [];
      errorDisponibilidad = e.toString();
    }
    loadingDisponibilidad = false;
    notifyListeners();
  }

  Future<void> createDisponibilidad({
    required int    docenteId,
    required String diaSemana,
    required String horaInicio,
    required String horaFin,
    bool            disponible             = true,
    String          motivo                 = '',
    String          tipoRestriccion        = 'PERMANENTE',
    String?         fechaInicioRestriccion,
    String?         fechaFinRestriccion,
  }) =>
      _createDisponibilidad(
        docenteId:              docenteId,
        diaSemana:              diaSemana,
        horaInicio:             horaInicio,
        horaFin:                horaFin,
        disponible:             disponible,
        motivo:                 motivo,
        tipoRestriccion:        tipoRestriccion,
        fechaInicioRestriccion: fechaInicioRestriccion,
        fechaFinRestriccion:    fechaFinRestriccion,
      );

  Future<void> updateDisponibilidad({
    required int    docenteId,
    required int    disponibilidadId,
    bool?           disponible,
    String?         motivo,
    String?         tipoRestriccion,
    String?         fechaInicioRestriccion,
    String?         fechaFinRestriccion,
  }) =>
      _updateDisponibilidad(
        docenteId:              docenteId,
        disponibilidadId:       disponibilidadId,
        disponible:             disponible,
        motivo:                 motivo,
        tipoRestriccion:        tipoRestriccion,
        fechaInicioRestriccion: fechaInicioRestriccion,
        fechaFinRestriccion:    fechaFinRestriccion,
      );

  Future<void> deleteDisponibilidad({
    required int docenteId,
    required int disponibilidadId,
  }) =>
      _deleteDisponibilidad(
        docenteId:        docenteId,
        disponibilidadId: disponibilidadId,
      );

  // ── Habilitaciones ────────────────────────────────────────────────────────

  Future<void> fetchHabilitaciones({
    int?    docenteId,
    String? nivel,
    bool?   activo,
    int     page = 1,
  }) async {
    loadingHabilitaciones = true;
    errorHabilitaciones   = null;
    notifyListeners();
    try {
      final result = await _getHabilitaciones(
        docenteId: docenteId, nivel: nivel, activo: activo, page: page,
      );
      habilitaciones      = result.results;
      habilitacionesTotal = result.count;
      habilitacionesPage  = page;
    } catch (e) {
      habilitaciones      = [];
      habilitacionesTotal = 0;
      errorHabilitaciones = e.toString();
    }
    loadingHabilitaciones = false;
    notifyListeners();
  }

  Future<void> createHabilitacion({
    required int    docenteId,
    required String nivel,
    int?            moduloId,
    int?            asignaturaId,
    required String fechaDesde,
    String?         fechaHasta,
    String          observaciones = '',
  }) =>
      _createHabilitacion(
        docenteId:    docenteId,
        nivel:        nivel,
        moduloId:     moduloId,
        asignaturaId: asignaturaId,
        fechaDesde:   fechaDesde,
        fechaHasta:   fechaHasta,
        observaciones: observaciones,
      );

  Future<void> updateHabilitacion({
    required int    habilitacionId,
    bool?           activo,
    String?         fechaHasta,
    String?         observaciones,
  }) =>
      _updateHabilitacion(
        habilitacionId: habilitacionId,
        activo:         activo,
        fechaHasta:     fechaHasta,
        observaciones:  observaciones,
      );
}
