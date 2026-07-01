// lib/features/programa/data/models/programa_model.dart
import '../../domain/entities/programa_entity.dart';
import 'version_programa_model.dart';

/// Coincide con ProgramaListSerializer.
class ProgramaResumenModel {
  final int id;
  final String nombre;
  final ProgramaNivel nivel;
  final String nivelDisplay;
  final ProgramaEstado estado;
  final String estadoDisplay;
  final ProgramaTipoFormacion tipoFormacion;
  final String tipoFormacionDisplay;
  final int horasLectivas;
  final int horasPracticas;
  final int totalHoras;
  final int totalVersiones;

  const ProgramaResumenModel({
    required this.id,
    required this.nombre,
    required this.nivel,
    required this.nivelDisplay,
    required this.estado,
    required this.estadoDisplay,
    required this.tipoFormacion,
    required this.tipoFormacionDisplay,
    required this.horasLectivas,
    required this.horasPracticas,
    required this.totalHoras,
    required this.totalVersiones,
  });

  factory ProgramaResumenModel.fromJson(Map<String, dynamic> json) {
    return ProgramaResumenModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      nivel: ProgramaNivel.fromValue(json['nivel'] as String),
      nivelDisplay: json['nivel_display'] as String? ?? '',
      estado: ProgramaEstado.fromValue(json['estado'] as String),
      estadoDisplay: json['estado_display'] as String? ?? '',
      tipoFormacion:
          ProgramaTipoFormacion.fromValue(json['tipo_formacion'] as String),
      tipoFormacionDisplay: json['tipo_formacion_display'] as String? ?? '',
      horasLectivas: json['horas_lectivas'] as int,
      horasPracticas: json['horas_practicas'] as int,
      totalHoras: json['total_horas'] as int,
      totalVersiones: json['total_versiones'] as int,
    );
  }

  ProgramaResumenEntity toEntity() => ProgramaResumenEntity(
        id: id,
        nombre: nombre,
        nivel: nivel,
        nivelDisplay: nivelDisplay,
        estado: estado,
        estadoDisplay: estadoDisplay,
        tipoFormacion: tipoFormacion,
        tipoFormacionDisplay: tipoFormacionDisplay,
        horasLectivas: horasLectivas,
        horasPracticas: horasPracticas,
        totalHoras: totalHoras,
        totalVersiones: totalVersiones,
      );
}

/// Coincide con ProgramaDetailSerializer.
class ProgramaModel {
  final int id;
  final String nombre;
  final String descripcion;
  final ProgramaNivel nivel;
  final String nivelDisplay;
  final int horasLectivas;
  final int horasPracticas;
  final int totalHoras;
  final ProgramaEstado estado;
  final String estadoDisplay;
  final int trimestresTotales;
  final ProgramaTipoFormacion tipoFormacion;
  final String tipoFormacionDisplay;
  final int? trimestresCadena;
  final List<VersionResumenModel> versiones;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProgramaModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.nivel,
    required this.nivelDisplay,
    required this.horasLectivas,
    required this.horasPracticas,
    required this.totalHoras,
    required this.estado,
    required this.estadoDisplay,
    required this.trimestresTotales,
    required this.tipoFormacion,
    required this.tipoFormacionDisplay,
    required this.trimestresCadena,
    required this.versiones,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProgramaModel.fromJson(Map<String, dynamic> json) {
    return ProgramaModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      nivel: ProgramaNivel.fromValue(json['nivel'] as String),
      nivelDisplay: json['nivel_display'] as String? ?? '',
      horasLectivas: json['horas_lectivas'] as int,
      horasPracticas: json['horas_practicas'] as int,
      totalHoras: json['total_horas'] as int,
      estado: ProgramaEstado.fromValue(json['estado'] as String),
      estadoDisplay: json['estado_display'] as String? ?? '',
      trimestresTotales: json['trimestres_totales'] as int,
      tipoFormacion:
          ProgramaTipoFormacion.fromValue(json['tipo_formacion'] as String),
      tipoFormacionDisplay: json['tipo_formacion_display'] as String? ?? '',
      trimestresCadena: json['trimestres_cadena'] as int?,
      versiones: (json['versiones'] as List<dynamic>? ?? [])
          .map((e) => VersionResumenModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  ProgramaEntity toEntity() => ProgramaEntity(
        id: id,
        nombre: nombre,
        descripcion: descripcion,
        nivel: nivel,
        nivelDisplay: nivelDisplay,
        horasLectivas: horasLectivas,
        horasPracticas: horasPracticas,
        totalHoras: totalHoras,
        estado: estado,
        estadoDisplay: estadoDisplay,
        trimestresTotales: trimestresTotales,
        tipoFormacion: tipoFormacion,
        tipoFormacionDisplay: tipoFormacionDisplay,
        trimestresCadena: trimestresCadena,
        versiones: versiones.map((v) => v.toEntity()).toList(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
