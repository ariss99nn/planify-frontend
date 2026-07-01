// lib/features/programa/data/models/modulo_model.dart
import '../../domain/entities/modulo_entity.dart';
import 'version_programa_model.dart';
import '../../../docentes/data/models/habilitacion_model.dart';

/// Coincide con ModuloListSerializer.
class ModuloResumenModel {
  final int id;
  final String nombre;
  final int orden;
  final int versionNumero;
  final ModuloEstado estado;
  final String estadoDisplay;
  final int horasLectivas;
  final int horasPracticas;
  final int totalHoras;
  final int totalAsignaturas;

  const ModuloResumenModel({
    required this.id,
    required this.nombre,
    required this.orden,
    required this.versionNumero,
    required this.estado,
    required this.estadoDisplay,
    required this.horasLectivas,
    required this.horasPracticas,
    required this.totalHoras,
    required this.totalAsignaturas,
  });

  factory ModuloResumenModel.fromJson(Map<String, dynamic> json) {
    return ModuloResumenModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      orden: json['orden'] as int,
      versionNumero: json['version_numero'] as int,
      estado: ModuloEstado.fromValue(json['estado'] as String),
      estadoDisplay: json['estado_display'] as String? ?? '',
      horasLectivas: json['horas_lectivas'] as int,
      horasPracticas: json['horas_practicas'] as int,
      totalHoras: json['total_horas'] as int,
      totalAsignaturas: json['total_asignaturas'] as int,
    );
  }

  ModuloResumenEntity toEntity() => ModuloResumenEntity(
        id: id,
        nombre: nombre,
        orden: orden,
        versionNumero: versionNumero,
        estado: estado,
        estadoDisplay: estadoDisplay,
        horasLectivas: horasLectivas,
        horasPracticas: horasPracticas,
        totalHoras: totalHoras,
        totalAsignaturas: totalAsignaturas,
      );
}

class ModuloModel {
  final int id;
  final VersionResumenModel version;
  final String nombre;
  final String descripcion;
  final int orden;
  final int horasLectivas;
  final int horasPracticas;
  final int totalHoras;
  final ModuloEstado estado;
  final String estadoDisplay;
  final List<HabilitacionModel> docentesAsignados;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ModuloModel({
    required this.id,
    required this.version,
    required this.nombre,
    required this.descripcion,
    required this.orden,
    required this.horasLectivas,
    required this.horasPracticas,
    required this.totalHoras,
    required this.estado,
    required this.estadoDisplay,
    required this.docentesAsignados,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ModuloModel.fromJson(Map<String, dynamic> json) {
    return ModuloModel(
      id: json['id'] as int,
      version: VersionResumenModel.fromJson(
          json['version'] as Map<String, dynamic>),
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      orden: json['orden'] as int,
      horasLectivas: json['horas_lectivas'] as int,
      horasPracticas: json['horas_practicas'] as int,
      totalHoras: json['total_horas'] as int,
      estado: ModuloEstado.fromValue(json['estado'] as String),
      estadoDisplay: json['estado_display'] as String? ?? '',
      docentesAsignados: (json['docentes_asignados'] as List<dynamic>? ?? [])
          .map(
              (e) => HabilitacionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  ModuloEntity toEntity() => ModuloEntity(
        id: id,
        version: version.toEntity(),
        nombre: nombre,
        descripcion: descripcion,
        orden: orden,
        horasLectivas: horasLectivas,
        horasPracticas: horasPracticas,
        totalHoras: totalHoras,
        estado: estado,
        estadoDisplay: estadoDisplay,
        docentesAsignados: docentesAsignados,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
