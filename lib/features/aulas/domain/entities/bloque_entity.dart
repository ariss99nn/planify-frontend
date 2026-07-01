// lib/features/aulas/domain/entities/bloque_entity.dart

class BloqueEntity {
  final int id;
  final String nombre;
  final int pisos;
  final int capacidadMaxima;
  final String estado;
  final String estadoDisplay;

  const BloqueEntity({
    required this.id,
    required this.nombre,
    required this.pisos,
    required this.capacidadMaxima,
    required this.estado,
    required this.estadoDisplay,
  });
}

class BloqueDetalleEntity {
  final int id;
  final String nombre;
  final int pisos;
  final int capacidadMaxima;
  final String estado;
  final String estadoDisplay;
  final String descripcion;
  final String? imagenUrl;
  final int? totalAulas;

  const BloqueDetalleEntity({
    required this.id,
    required this.nombre,
    required this.pisos,
    required this.capacidadMaxima,
    required this.estado,
    required this.estadoDisplay,
    required this.descripcion,
    this.imagenUrl,
    this.totalAulas,
  });
}

class BloqueResumenEntity {
  final int id;
  final String nombre;
  final int pisos;
  final int capacidadMaxima;
  final String estado;
  final String estadoDisplay;

  const BloqueResumenEntity({
    required this.id,
    required this.nombre,
    required this.pisos,
    required this.capacidadMaxima,
    required this.estado,
    required this.estadoDisplay,
  });
}