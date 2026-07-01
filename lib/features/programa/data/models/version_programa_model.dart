// lib/features/programa/data/models/version_programa_model.dart
import '../../domain/entities/version_programa_entity.dart';
import 'programa_model.dart';
import 'modulo_model.dart';

/// Coincide con VersionListSerializer.
class VersionResumenModel {
  final int id;
  final int numero;
  final int programaId;
  final String programaNombre;
  final bool vigente;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final int totalModulos;
  final int totalHoras;

  const VersionResumenModel({
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

  factory VersionResumenModel.fromJson(Map<String, dynamic> json) {
    return VersionResumenModel(
      id: json['id'] as int,
      numero: json['numero'] as int,
      programaId: json['programa'] as int,
      programaNombre: json['programa_nombre'] as String? ?? '',
      vigente: json['vigente'] as bool,
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFin: json['fecha_fin'] != null
          ? DateTime.parse(json['fecha_fin'] as String)
          : null,
      totalModulos: json['total_modulos'] as int,
      totalHoras: json['total_horas'] as int,
    );
  }

  VersionResumenEntity toEntity() => VersionResumenEntity(
        id: id,
        numero: numero,
        programaId: programaId,
        programaNombre: programaNombre,
        vigente: vigente,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        totalModulos: totalModulos,
        totalHoras: totalHoras,
      );
}

/// Coincide con VersionDetailSerializer.
class VersionModel {
  final int id;
  final ProgramaResumenModel programa;
  final int numero;
  final String descripcion;
  final bool vigente;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final int totalHoras;
  final List<ModuloResumenModel> modulos;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VersionModel({
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

  factory VersionModel.fromJson(Map<String, dynamic> json) {
    return VersionModel(
      id: json['id'] as int,
      programa: ProgramaResumenModel.fromJson(
          json['programa'] as Map<String, dynamic>),
      numero: json['numero'] as int,
      descripcion: json['descripcion'] as String? ?? '',
      vigente: json['vigente'] as bool,
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFin: json['fecha_fin'] != null
          ? DateTime.parse(json['fecha_fin'] as String)
          : null,
      totalHoras: json['total_horas'] as int,
      modulos: (json['modulos'] as List<dynamic>? ?? [])
          .map((e) => ModuloResumenModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  VersionEntity toEntity() => VersionEntity(
        id: id,
        programa: programa.toEntity(),
        numero: numero,
        descripcion: descripcion,
        vigente: vigente,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        totalHoras: totalHoras,
        modulos: modulos.map((m) => m.toEntity()).toList(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
