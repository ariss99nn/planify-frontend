// lib/features/docentes/domain/entities/disponibilidad_entity.dart

class DisponibilidadEntity {
  final int     id;
  final int     docenteId;
  final String  docenteNombre;
  final String  diaSemana;
  final String  diaDisplay;
  final String  horaInicio;
  final String  horaFin;
  final bool    disponible;
  final String  motivo;
  final String  tipoRestriccion;
  final String  tipoRestriccionDisplay;
  final String? fechaInicioRestriccion;
  final String? fechaFinRestriccion;

  const DisponibilidadEntity({
    required this.id,
    required this.docenteId,
    required this.docenteNombre,
    required this.diaSemana,
    required this.diaDisplay,
    required this.horaInicio,
    required this.horaFin,
    required this.disponible,
    required this.motivo,
    required this.tipoRestriccion,
    required this.tipoRestriccionDisplay,
    this.fechaInicioRestriccion,
    this.fechaFinRestriccion,
  });

  static String _fmt(String h) => h.length >= 5 ? h.substring(0, 5) : h;

  String get bloqueDetalle => '$diaDisplay ${_fmt(horaInicio)}–${_fmt(horaFin)}';

  bool get esTemporal => tipoRestriccion == 'TEMPORAL';
}
