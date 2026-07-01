// lib/features/programa/domain/entities/modulo_entity.dart
import 'version_programa_entity.dart';
import '../../../docentes/data/models/habilitacion_model.dart';

enum ModuloEstado {
  activo('ACTIVO', 'Activo'),
  inactivo('INACTIVO', 'Inactivo');

  final String value;
  final String label;
  const ModuloEstado(this.value, this.label);

  static ModuloEstado fromValue(String value) => values.firstWhere(
        (e) => e.value == value,
        orElse: () => ModuloEstado.activo,
      );
}

/// Resumen de módulo (coincide con ModuloListSerializer).
class ModuloResumenEntity {
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

  const ModuloResumenEntity({
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

  /// `totalAsignaturas` no viene en ModuloDetailSerializer, así que debe
  /// suministrarse desde el llamador (0 para un módulo recién creado,
  /// o el valor ya conocido en la lista al actualizar uno existente).
  factory ModuloResumenEntity.fromDetail(
    ModuloEntity m, {
    required int totalAsignaturas,
  }) {
    return ModuloResumenEntity(
      id: m.id,
      nombre: m.nombre,
      orden: m.orden,
      versionNumero: m.version.numero,
      estado: m.estado,
      estadoDisplay: m.estadoDisplay,
      horasLectivas: m.horasLectivas,
      horasPracticas: m.horasPracticas,
      totalHoras: m.totalHoras,
      totalAsignaturas: totalAsignaturas,
    );
  }
}

/// Detalle de módulo (coincide con ModuloDetailSerializer).
class ModuloEntity {
  final int id;
  final VersionResumenEntity version;
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

  const ModuloEntity({
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
}
