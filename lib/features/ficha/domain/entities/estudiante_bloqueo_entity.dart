// lib/features/ficha/domain/entities/estudiante_bloqueo_entity.dart

class EstudianteBloqueoEntity {
  final int id;
  final int estudiante;
  final String estudianteNombre;
  final String estudianteEmail;
  final String motivo;
  final String motivoDisplay;
  final String? fichaOrigenCodigo;
  final bool activo;
  final bool vigente;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? desbloqueadoPorNombre;
  final DateTime? fechaDesbloqueo;
  final String observacionDesbloqueo;

  const EstudianteBloqueoEntity({
    required this.id,
    required this.estudiante,
    required this.estudianteNombre,
    required this.estudianteEmail,
    required this.motivo,
    required this.motivoDisplay,
    this.fichaOrigenCodigo,
    required this.activo,
    required this.vigente,
    required this.fechaInicio,
    required this.fechaFin,
    this.desbloqueadoPorNombre,
    this.fechaDesbloqueo,
    this.observacionDesbloqueo = '',
  });
}
