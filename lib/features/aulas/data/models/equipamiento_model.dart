// lib/features/aulas/data/models/equipamiento_model.dart

import '../../domain/entities/equipamiento_entity.dart';

class EquipamientoModel {
  final int id;
  final String nombre;
  final int cantidad;
  final String estado;
  final String estadoDisplay;

  const EquipamientoModel({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.estado,
    required this.estadoDisplay,
  });

  factory EquipamientoModel.fromJson(Map<String, dynamic> json) => EquipamientoModel(
        id:            json['id'] as int,
        nombre:        json['nombre'] as String,
        cantidad:      json['cantidad'] as int,
        estado:        json['estado'] as String,
        estadoDisplay: json['estado_display'] as String,
      );

  EquipamientoEntity toEntity() => EquipamientoEntity(
        id:            id,
        nombre:        nombre,
        cantidad:      cantidad,
        estado:        estado,
        estadoDisplay: estadoDisplay,
      );
}

class EquipamientoDetalleModel {
  final int id;
  final String nombre;
  final String descripcion;
  final int cantidad;
  final String? numeroSerie;
  final String? fechaAdquisicion;
  final String estado;
  final String estadoDisplay;
  final String? imagenUrl;

  const EquipamientoDetalleModel({
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

  factory EquipamientoDetalleModel.fromJson(Map<String, dynamic> json) =>
      EquipamientoDetalleModel(
        id:               json['id'] as int,
        nombre:           json['nombre'] as String,
        descripcion:      json['descripcion'] as String? ?? '',
        cantidad:         json['cantidad'] as int,
        numeroSerie:      json['numero_serie'] as String?,
        fechaAdquisicion: json['fecha_adquisicion'] as String?,
        estado:           json['estado'] as String,
        estadoDisplay:    json['estado_display'] as String,
        imagenUrl:        json['imagen'] as String?,
      );

  EquipamientoDetalleEntity toEntity() => EquipamientoDetalleEntity(
        id:               id,
        nombre:           nombre,
        descripcion:      descripcion,
        cantidad:         cantidad,
        numeroSerie:      numeroSerie,
        fechaAdquisicion: fechaAdquisicion,
        estado:           estado,
        estadoDisplay:    estadoDisplay,
        imagenUrl:        imagenUrl,
      );
}

class EquipamientoResumenModel {
  final int id;
  final String nombre;
  final int cantidad;
  final String estado;
  final String estadoDisplay;

  const EquipamientoResumenModel({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.estado,
    required this.estadoDisplay,
  });

  factory EquipamientoResumenModel.fromJson(Map<String, dynamic> json) =>
      EquipamientoResumenModel(
        id:            json['id'] as int,
        nombre:        json['nombre'] as String,
        cantidad:      json['cantidad'] as int,
        estado:        json['estado'] as String,
        estadoDisplay: json['estado_display'] as String,
      );

  EquipamientoResumenEntity toEntity() => EquipamientoResumenEntity(
        id:            id,
        nombre:        nombre,
        cantidad:      cantidad,
        estado:        estado,
        estadoDisplay: estadoDisplay,
      );
}