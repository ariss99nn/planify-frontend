// lib/features/aulas/data/models/bloque_model.dart

import '../../domain/entities/bloque_entity.dart';

class BloqueModel {
  final int id;
  final String nombre;
  final int pisos;
  final int capacidadMaxima;
  final String estado;
  final String estadoDisplay;

  const BloqueModel({
    required this.id,
    required this.nombre,
    required this.pisos,
    required this.capacidadMaxima,
    required this.estado,
    required this.estadoDisplay,
  });

  factory BloqueModel.fromJson(Map<String, dynamic> json) => BloqueModel(
        id:              json['id'] as int,
        nombre:          json['nombre'] as String,
        pisos:           json['pisos'] as int,
        capacidadMaxima: json['capacidad_maxima'] as int,
        estado:          json['estado'] as String? ?? 'ACT',
        estadoDisplay:   json['estado_display'] as String? ?? '',
      );

  BloqueEntity toEntity() => BloqueEntity(
        id:              id,
        nombre:          nombre,
        pisos:           pisos,
        capacidadMaxima: capacidadMaxima,
        estado:          estado,
        estadoDisplay:   estadoDisplay,
      );
}

class BloqueDetalleModel {
  final int id;
  final String nombre;
  final int pisos;
  final int capacidadMaxima;
  final String estado;
  final String estadoDisplay;
  final String descripcion;
  final String? imagenUrl;
  final int? totalAulas;

  const BloqueDetalleModel({
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

  factory BloqueDetalleModel.fromJson(Map<String, dynamic> json) => BloqueDetalleModel(
        id:              json['id'] as int,
        nombre:          json['nombre'] as String,
        pisos:           json['pisos'] as int,
        capacidadMaxima: json['capacidad_maxima'] as int,
        estado:          json['estado'] as String? ?? 'ACT',
        estadoDisplay:   json['estado_display'] as String? ?? '',
        descripcion:     json['descripcion'] as String? ?? '',
        imagenUrl:       json['imagen'] as String?,
        totalAulas:      json['total_aulas'] as int?,
      );

  BloqueDetalleEntity toEntity() => BloqueDetalleEntity(
        id:              id,
        nombre:          nombre,
        pisos:           pisos,
        capacidadMaxima: capacidadMaxima,
        estado:          estado,
        estadoDisplay:   estadoDisplay,
        descripcion:     descripcion,
        imagenUrl:       imagenUrl,
        totalAulas:      totalAulas,
      );
}

class BloqueResumenModel {
  final int id;
  final String nombre;
  final int pisos;
  final int capacidadMaxima;
  final String estado;
  final String estadoDisplay;

  const BloqueResumenModel({
    required this.id,
    required this.nombre,
    required this.pisos,
    required this.capacidadMaxima,
    required this.estado,
    required this.estadoDisplay,
  });

  factory BloqueResumenModel.fromJson(Map<String, dynamic> json) => BloqueResumenModel(
        id:              json['id'] as int,
        nombre:          json['nombre'] as String,
        pisos:           json['pisos'] as int,
        capacidadMaxima: json['capacidad_maxima'] as int,
        estado:          json['estado'] as String? ?? 'ACT',
        estadoDisplay:   json['estado_display'] as String? ?? '',
      );

  BloqueResumenEntity toEntity() => BloqueResumenEntity(
        id:              id,
        nombre:          nombre,
        pisos:           pisos,
        capacidadMaxima: capacidadMaxima,
        estado:          estado,
        estadoDisplay:   estadoDisplay,
      );
}