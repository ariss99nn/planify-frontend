// lib/features/docentes/domain/repositories/docente_repository.dart

import 'package:image_picker/image_picker.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/docente_entity.dart';
import '../entities/disponibilidad_entity.dart';
import '../entities/habilitacion_entity.dart';

abstract class DocenteRepository {
  Future<PaginatedResponse<DocenteEntity>> getDocentes({
    String? search,
    bool?   estado,
    String? especialidad,
    int     page = 1,
  });

  Future<DocenteEntity> getDocente(int id);

  Future<void> createDocente({
    required int    userId,
    required String especialidad,
    required int    horasMaxSemanales,
    bool            estado,
    bool            permiteHorasExtra,
    int             horasExtraAutorizadas,
    XFile?          imagen,
  });

  Future<void> updateDocente({
    required int                  id,
    required Map<String, dynamic> data,
    XFile?                        imagen,
    bool                          eliminarImagen,
  });

  Future<void> deactivateDocente(int id);

  // ── Disponibilidad ────────────────────────────────────────────────────────

  Future<List<DisponibilidadEntity>> getDisponibilidad(int docenteId);

  Future<void> createDisponibilidad({
    required int    docenteId,
    required String diaSemana,
    required String horaInicio,
    required String horaFin,
    bool            disponible,
    String          motivo,
    String          tipoRestriccion,
    String?         fechaInicioRestriccion,
    String?         fechaFinRestriccion,
  });

  Future<void> updateDisponibilidad({
    required int    docenteId,
    required int    disponibilidadId,
    bool?           disponible,
    String?         motivo,
    String?         tipoRestriccion,
    String?         fechaInicioRestriccion,
    String?         fechaFinRestriccion,
  });

  Future<void> deleteDisponibilidad({
    required int docenteId,
    required int disponibilidadId,
  });

  // ── Habilitaciones ────────────────────────────────────────────────────────

  Future<PaginatedResponse<HabilitacionEntity>> getHabilitaciones({
    int?    docenteId,
    String? nivel,
    bool?   activo,
    int     page = 1,
  });

  Future<void> createHabilitacion({
    required int    docenteId,
    required String nivel,
    int?            moduloId,
    int?            asignaturaId,
    required String fechaDesde,
    String?         fechaHasta,
    String          observaciones,
  });

  Future<void> updateHabilitacion({
    required int    habilitacionId,
    bool?           activo,
    String?         fechaHasta,
    String?         observaciones,
  });
}
