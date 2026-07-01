// lib/features/programa/domain/entities/version_programa_entity.dart
import 'programa_entity.dart';
import 'modulo_entity.dart';

/// Resumen de versión (coincide con VersionListSerializer).
class VersionResumenEntity {
  final int id;
  final int numero;
  final int programaId;
  final String programaNombre;
  final bool vigente;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final int totalModulos;
  final int totalHoras;

  const VersionResumenEntity({
    required this.id,
    required this.numero,
    required this.programaId,
    required this.programaNombre,
    required this.vigente,
    required this.fechaInicio,
    required this.fechaFin,
    required this.totalModulos,
    required this.totalHoras,
  });

  VersionResumenEntity copyWith({bool? vigente}) {
    return VersionResumenEntity(
      id: id,
      numero: numero,
      programaId: programaId,
      programaNombre: programaNombre,
      vigente: vigente ?? this.vigente,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      totalModulos: totalModulos,
      totalHoras: totalHoras,
    );
  }

  factory VersionResumenEntity.fromDetail(VersionEntity v) {
    return VersionResumenEntity(
      id: v.id,
      numero: v.numero,
      programaId: v.programa.id,
      programaNombre: v.programa.nombre,
      vigente: v.vigente,
      fechaInicio: v.fechaInicio,
      fechaFin: v.fechaFin,
      totalModulos: v.modulos.length,
      totalHoras: v.totalHoras,
    );
  }
}

/// Detalle de versión (coincide con VersionDetailSerializer).
class VersionEntity {
  final int id;
  final ProgramaResumenEntity programa;
  final int numero;
  final String descripcion;
  final bool vigente;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final int totalHoras;
  final List<ModuloResumenEntity> modulos;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VersionEntity({
    required this.id,
    required this.programa,
    required this.numero,
    required this.descripcion,
    required this.vigente,
    required this.fechaInicio,
    required this.fechaFin,
    required this.totalHoras,
    required this.modulos,
    required this.createdAt,
    required this.updatedAt,
  });
}
