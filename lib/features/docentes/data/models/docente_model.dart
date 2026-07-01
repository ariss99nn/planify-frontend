// lib/features/docentes/data/models/docente_model.dart

import '../../../../core/api/api_service.dart';
import '../../domain/entities/docente_entity.dart';

class DocenteModel extends DocenteEntity {
  const DocenteModel({
    required super.id,
    super.userId,
    required super.nombre,
    required super.email,
    required super.especialidad,
    required super.horasMaxSemanales,
    required super.permiteHorasExtra,
    required super.horasExtraAutorizadas,
    super.horasMaxEfectivas,
    super.horasAsignadasSemana,
    super.estaSobrecargado,
    required super.estado,
    super.imagenUrl,
    super.avatarUrl,
  });

  factory DocenteModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return DocenteModel(
      id:                    json['id']                      as int,
      userId:                user?['id']                     as int?,
      nombre:                user?['nombre_completo']        as String?
                          ?? json['nombre']                  as String? ?? '',
      email:                 user?['email']                  as String?
                          ?? json['email']                   as String? ?? '',
      especialidad:          json['especialidad']            as String? ?? '',
      horasMaxSemanales:     json['horas_max_semanales']     as int?    ?? 0,
      permiteHorasExtra:     json['permite_horas_extra']     as bool?   ?? false,
      horasExtraAutorizadas: json['horas_extra_autorizadas'] as int?    ?? 0,
      horasMaxEfectivas:     json['horas_max_efectivas']     as int?,
      horasAsignadasSemana:  (json['horas_asignadas_semana'] as num?)?.toDouble(),
      estaSobrecargado:      json['esta_sobrecargado']       as bool?,
      estado:                json['estado']                  as bool?   ?? true,
      avatarUrl: ApiService.buildMediaUrl(
        user?['imagen'] as String? ?? json['avatar'] as String?,
      ),
      imagenUrl: ApiService.buildMediaUrl(json['imagen'] as String?),
    );
  }
}
