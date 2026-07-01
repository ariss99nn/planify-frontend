// lib/features/docentes/data/repositories_impl/docente_repository_impl.dart

import 'package:image_picker/image_picker.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/docente_entity.dart';
import '../../domain/entities/disponibilidad_entity.dart';
import '../../domain/entities/habilitacion_entity.dart';
import '../../domain/repositories/docente_repository.dart';
import '../datasources/docente_remote_datasource.dart';
import '../models/docente_model.dart';
import '../models/disponibilidad_model.dart';
import '../models/habilitacion_model.dart';

class DocenteRepositoryImpl implements DocenteRepository {
  @override
  Future<PaginatedResponse<DocenteEntity>> getDocentes({
    String? search,
    bool?   estado,
    String? especialidad,
    int     page = 1,
  }) async {
    final data = await DocenteRemoteDatasource.getDocentes(
      search: search, estado: estado, especialidad: especialidad, page: page,
    );
    return PaginatedResponse.fromJson(
      data as Map<String, dynamic>,
      DocenteModel.fromJson,
    );
  }

  @override
  Future<DocenteEntity> getDocente(int id) async {
    final data = await DocenteRemoteDatasource.getDocente(id);
    return DocenteModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> createDocente({
    required int    userId,
    required String especialidad,
    required int    horasMaxSemanales,
    bool            estado                = true,
    bool            permiteHorasExtra     = false,
    int             horasExtraAutorizadas = 0,
    XFile?          imagen,
  }) =>
      DocenteRemoteDatasource.createDocente(
        userId:               userId,
        especialidad:         especialidad,
        horasMaxSemanales:    horasMaxSemanales,
        estado:               estado,
        permiteHorasExtra:    permiteHorasExtra,
        horasExtraAutorizadas: horasExtraAutorizadas,
        imagen:               imagen,
      );

  @override
  Future<void> updateDocente({
    required int                  id,
    required Map<String, dynamic> data,
    XFile?                        imagen,
    bool                          eliminarImagen = false,
  }) =>
      DocenteRemoteDatasource.updateDocente(
        id: id, data: data, imagen: imagen, eliminarImagen: eliminarImagen,
      );

  @override
  Future<void> deactivateDocente(int id) =>
      DocenteRemoteDatasource.deactivateDocente(id);

  // ── Disponibilidad ────────────────────────────────────────────────────────

  @override
  Future<List<DisponibilidadEntity>> getDisponibilidad(int docenteId) async {
    final data = await DocenteRemoteDatasource.getDisponibilidad(docenteId);
    return (data as List)
        .map((e) => DisponibilidadModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
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
      DocenteRemoteDatasource.createDisponibilidad(
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

  @override
  Future<void> updateDisponibilidad({
    required int    docenteId,
    required int    disponibilidadId,
    bool?           disponible,
    String?         motivo,
    String?         tipoRestriccion,
    String?         fechaInicioRestriccion,
    String?         fechaFinRestriccion,
  }) =>
      DocenteRemoteDatasource.updateDisponibilidad(
        docenteId:              docenteId,
        disponibilidadId:       disponibilidadId,
        disponible:             disponible,
        motivo:                 motivo,
        tipoRestriccion:        tipoRestriccion,
        fechaInicioRestriccion: fechaInicioRestriccion,
        fechaFinRestriccion:    fechaFinRestriccion,
      );

  @override
  Future<void> deleteDisponibilidad({
    required int docenteId,
    required int disponibilidadId,
  }) =>
      DocenteRemoteDatasource.deleteDisponibilidad(
        docenteId:        docenteId,
        disponibilidadId: disponibilidadId,
      );

  // ── Habilitaciones ────────────────────────────────────────────────────────

  @override
  Future<PaginatedResponse<HabilitacionEntity>> getHabilitaciones({
    int?    docenteId,
    String? nivel,
    bool?   activo,
    int     page = 1,
  }) async {
    final data = await DocenteRemoteDatasource.getHabilitaciones(
      docenteId: docenteId, nivel: nivel, activo: activo, page: page,
    );
    return PaginatedResponse.fromJson(
      data as Map<String, dynamic>,
      HabilitacionModel.fromJson,
    );
  }

  @override
  Future<void> createHabilitacion({
    required int    docenteId,
    required String nivel,
    int?            moduloId,
    int?            asignaturaId,
    required String fechaDesde,
    String?         fechaHasta,
    String          observaciones = '',
  }) =>
      DocenteRemoteDatasource.createHabilitacion(
        docenteId:    docenteId,
        nivel:        nivel,
        moduloId:     moduloId,
        asignaturaId: asignaturaId,
        fechaDesde:   fechaDesde,
        fechaHasta:   fechaHasta,
        observaciones: observaciones,
      );

  @override
  Future<void> updateHabilitacion({
    required int    habilitacionId,
    bool?           activo,
    String?         fechaHasta,
    String?         observaciones,
  }) =>
      DocenteRemoteDatasource.updateHabilitacion(
        habilitacionId: habilitacionId,
        activo:         activo,
        fechaHasta:     fechaHasta,
        observaciones:  observaciones,
      );
}
