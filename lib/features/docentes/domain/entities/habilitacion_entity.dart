// lib/features/docentes/domain/entities/habilitacion_entity.dart

enum HabilitacionNivel {
  modulo('MODULO', 'Módulo'),
  asignatura('ASIGNATURA', 'Asignatura');

  final String value;
  final String label;
  const HabilitacionNivel(this.value, this.label);

  static HabilitacionNivel fromValue(String value) => values.firstWhere(
        (e) => e.value == value,
        orElse: () => HabilitacionNivel.modulo,
      );
}

class HabilitacionEntity {
  final int               id;
  final int               docenteId;
  final String            docenteNombre;
  final HabilitacionNivel nivel;
  final String            nivelDisplay;
  final int?              moduloId;
  final String?           moduloNombre;
  final int?              asignaturaId;
  final String?           asignaturaNombre;
  final bool              activo;
  final DateTime          fechaDesde;
  final DateTime?         fechaHasta;
  final String            observaciones;

  const HabilitacionEntity({
    required this.id,
    required this.docenteId,
    required this.docenteNombre,
    required this.nivel,
    required this.nivelDisplay,
    required this.moduloId,
    required this.moduloNombre,
    required this.asignaturaId,
    required this.asignaturaNombre,
    required this.activo,
    required this.fechaDesde,
    required this.fechaHasta,
    required this.observaciones,
  });
}
