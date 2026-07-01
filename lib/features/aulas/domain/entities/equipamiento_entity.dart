// lib/features/aulas/domain/entities/equipamiento_entity.dart

class EquipamientoEntity {
  final int id;
  final String nombre;
  final int cantidad;
  final String estado;
  final String estadoDisplay;

  const EquipamientoEntity({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.estado,
    required this.estadoDisplay,
  });
}

class EquipamientoDetalleEntity {
  final int id;
  final String nombre;
  final String descripcion;
  final int cantidad;
  final String? numeroSerie;
  final String? fechaAdquisicion;
  final String estado;
  final String estadoDisplay;
  final String? imagenUrl;

  const EquipamientoDetalleEntity({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.cantidad,
    required this.estado,
    required this.estadoDisplay,
    this.numeroSerie,
    this.fechaAdquisicion,
    this.imagenUrl,
  });
}

class EquipamientoResumenEntity {
  final int id;
  final String nombre;
  final int cantidad;
  final String estado;
  final String estadoDisplay;

  const EquipamientoResumenEntity({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.estado,
    required this.estadoDisplay,
  });
}