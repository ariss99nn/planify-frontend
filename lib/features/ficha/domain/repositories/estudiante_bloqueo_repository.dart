// lib/features/ficha/domain/repositories/estudiante_bloqueo_repository.dart

import '../../../../core/models/paginated_response.dart';
import '../entities/estudiante_bloqueo_entity.dart';

abstract class EstudianteBloqueoRepository {
  Future<PaginatedResponse<EstudianteBloqueoEntity>> listar({bool? activo});

  Future<EstudianteBloqueoEntity> desbloquear(int id, {String observacion});
}
