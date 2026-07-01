// lib/features/docentes/domain/usecases/docente_usecases.dart

import 'package:image_picker/image_picker.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/docente_entity.dart';
import '../entities/disponibilidad_entity.dart';
import '../entities/habilitacion_entity.dart';
import '../repositories/docente_repository.dart';

class GetDocentesUseCase {
  final DocenteRepository _repo;
  const GetDocentesUseCase(this._repo);

  Future<PaginatedResponse<DocenteEntity>> call({
    String? search,
    bool?   estado,
    String? especialidad,
    int     page = 1,
  }) =>
      _repo.getDocentes(
          search: search, estado: estado, especialidad: especialidad, page: page);
}

class GetDocenteUseCase {
  final DocenteRepository _repo;
  const GetDocenteUseCase(this._repo);

  Future<DocenteEntity> call(int id) => _repo.getDocente(id);
}

class CreateDocenteUseCase {
  final DocenteRepository _repo;
  const CreateDocenteUseCase(this._repo);

  Future<void> call({
    required int    userId,
    required String especialidad,
    required int    horasMaxSemanales,
    bool            estado                = true,
    bool            permiteHorasExtra     = false,
    int             horasExtraAutorizadas = 0,
    XFile?          imagen,
  }) =>
      _repo.createDocente(
        userId:               userId,
        especialidad:         especialidad,
        horasMaxSemanales:    horasMaxSemanales,
        estado:               estado,
        permiteHorasExtra:    permiteHorasExtra,
        horasExtraAutorizadas: horasExtraAutorizadas,
        imagen:               imagen,
      );
}

class UpdateDocenteUseCase {
  final DocenteRepository _repo;
  const UpdateDocenteUseCase(this._repo);

  Future<void> call({
    required int                  id,
    required Map<String, dynamic> data,
    XFile?                        imagen,
    bool                          eliminarImagen = false,
  }) =>
      _repo.updateDocente(
          id: id, data: data, imagen: imagen, eliminarImagen: eliminarImagen);
}

class DeactivateDocenteUseCase {
  final DocenteRepository _repo;
  const DeactivateDocenteUseCase(this._repo);

  Future<void> call(int id) => _repo.deactivateDocente(id);
}

// ── Disponibilidad ─────────────────────────────────────────────────────────

class GetDisponibilidadUseCase {
  final DocenteRepository _repo;
  const GetDisponibilidadUseCase(this._repo);

  Future<List<DisponibilidadEntity>> call(int docenteId) =>
      _repo.getDisponibilidad(docenteId);
}

class CreateDisponibilidadUseCase {
  final DocenteRepository _repo;
  const CreateDisponibilidadUseCase(this._repo);

  Future<void> call({
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
      _repo.createDisponibilidad(
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
}

class UpdateDisponibilidadUseCase {
  final DocenteRepository _repo;
  const UpdateDisponibilidadUseCase(this._repo);

  Future<void> call({
    required int    docenteId,
    required int    disponibilidadId,
    bool?           disponible,
    String?         motivo,
    String?         tipoRestriccion,
    String?         fechaInicioRestriccion,
    String?         fechaFinRestriccion,
  }) =>
      _repo.updateDisponibilidad(
        docenteId:              docenteId,
        disponibilidadId:       disponibilidadId,
        disponible:             disponible,
        motivo:                 motivo,
        tipoRestriccion:        tipoRestriccion,
        fechaInicioRestriccion: fechaInicioRestriccion,
        fechaFinRestriccion:    fechaFinRestriccion,
      );
}

class DeleteDisponibilidadUseCase {
  final DocenteRepository _repo;
  const DeleteDisponibilidadUseCase(this._repo);

  Future<void> call({required int docenteId, required int disponibilidadId}) =>
      _repo.deleteDisponibilidad(
          docenteId: docenteId, disponibilidadId: disponibilidadId);
}

// ── Habilitaciones ─────────────────────────────────────────────────────────

class GetHabilitacionesUseCase {
  final DocenteRepository _repo;
  const GetHabilitacionesUseCase(this._repo);

  Future<PaginatedResponse<HabilitacionEntity>> call({
    int?    docenteId,
    String? nivel,
    bool?   activo,
    int     page = 1,
  }) =>
      _repo.getHabilitaciones(
          docenteId: docenteId, nivel: nivel, activo: activo, page: page);
}

class CreateHabilitacionUseCase {
  final DocenteRepository _repo;
  const CreateHabilitacionUseCase(this._repo);

  Future<void> call({
    required int    docenteId,
    required String nivel,
    int?            moduloId,
    int?            asignaturaId,
    required String fechaDesde,
    String?         fechaHasta,
    String          observaciones = '',
  }) =>
      _repo.createHabilitacion(
        docenteId:    docenteId,
        nivel:        nivel,
        moduloId:     moduloId,
        asignaturaId: asignaturaId,
        fechaDesde:   fechaDesde,
        fechaHasta:   fechaHasta,
        observaciones: observaciones,
      );
}

class UpdateHabilitacionUseCase {
  final DocenteRepository _repo;
  const UpdateHabilitacionUseCase(this._repo);

  Future<void> call({
    required int    habilitacionId,
    bool?           activo,
    String?         fechaHasta,
    String?         observaciones,
  }) =>
      _repo.updateHabilitacion(
        habilitacionId: habilitacionId,
        activo:         activo,
        fechaHasta:     fechaHasta,
        observaciones:  observaciones,
      );
}
