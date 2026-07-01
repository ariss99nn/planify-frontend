// lib/features/aulas/data/models/aula_model.dart

import '../../domain/entities/aula_entity.dart';
import '../../domain/entities/bloque_entity.dart';
import '../../domain/entities/equipamiento_entity.dart';
import 'bloque_model.dart';
import 'equipamiento_model.dart';

class AulaModel {
  final int id;
  final String codigoAula;
  final int capacidad;
  final String tipoAula;
  final String tipoAulaDisplay;
  final String estado;
  final String estadoDisplay;
  final BloqueModel bloque;
  final int piso;
  final String descripcion;
  final String? imagenUrl;
  final List<EquipamientoModel> equipamiento;

  const AulaModel({
    required this.id,
    required this.codigoAula,
    required this.capacidad,
    required this.tipoAula,
    required this.tipoAulaDisplay,
    required this.estado,
    required this.estadoDisplay,
    required this.bloque,
    required this.piso,
    required this.descripcion,
    this.imagenUrl,
    required this.equipamiento,
  });

  factory AulaModel.fromJson(Map<String, dynamic> json) => AulaModel(
        id:              json['id'] as int,
        codigoAula:      json['codigo_aula'] as String,
        capacidad:       json['capacidad'] as int,
        tipoAula:        json['tipo_aula'] as String,
        tipoAulaDisplay: json['tipo_aula_display'] as String,
        estado:          json['estado'] as String,
        estadoDisplay:   json['estado_display'] as String,
        bloque:          BloqueModel.fromJson(json['bloque'] as Map<String, dynamic>),
        piso:            json['piso'] as int,
        descripcion:     json['descripcion'] as String? ?? '',
        imagenUrl:       json['imagen'] as String?,
        equipamiento:    (json['equipamiento'] as List<dynamic>? ?? [])
            .map((e) => EquipamientoModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  AulaEntity toEntity() => AulaEntity(
        id:              id,
        codigoAula:      codigoAula,
        capacidad:       capacidad,
        tipoAula:        tipoAula,
        tipoAulaDisplay: tipoAulaDisplay,
        estado:          estado,
        estadoDisplay:   estadoDisplay,
        bloque:          BloqueEntity(
          id:              bloque.id,
          nombre:          bloque.nombre,
          pisos:           bloque.pisos,
          capacidadMaxima: bloque.capacidadMaxima,
          estado:          bloque.estado,
          estadoDisplay:   bloque.estadoDisplay,
        ),
        piso:             piso,
        descripcion:      descripcion,
        imagenUrl:        imagenUrl,
        equipamiento:     equipamiento.map((e) => EquipamientoEntity(
          id:            e.id,
          nombre:        e.nombre,
          cantidad:      e.cantidad,
          estado:        e.estado,
          estadoDisplay: e.estadoDisplay,
        )).toList(),
      );
}

class AulaResumenModel {
  final int id;
  final String codigoAula;
  final int capacidad;
  final String tipoAula;
  final String tipoAulaDisplay;
  final String estado;
  final String estadoDisplay;
  final String bloqueNombre;
  final int piso;

  const AulaResumenModel({
    required this.id,
    required this.codigoAula,
    required this.capacidad,
    required this.tipoAula,
    required this.tipoAulaDisplay,
    required this.estado,
    required this.estadoDisplay,
    required this.bloqueNombre,
    required this.piso,
  });

  factory AulaResumenModel.fromJson(Map<String, dynamic> json) => AulaResumenModel(
        id:              json['id'] as int,
        codigoAula:      json['codigo_aula'] as String,
        capacidad:       json['capacidad'] as int,
        tipoAula:        json['tipo_aula'] as String,
        tipoAulaDisplay: json['tipo_aula_display'] as String,
        estado:          json['estado'] as String,
        estadoDisplay:   json['estado_display'] as String,
        bloqueNombre:    json['bloque_nombre'] as String,
        piso:            json['piso'] as int,
      );

  AulaResumenEntity toEntity() => AulaResumenEntity(
        id:              id,
        codigoAula:      codigoAula,
        capacidad:       capacidad,
        tipoAula:        tipoAula,
        tipoAulaDisplay: tipoAulaDisplay,
        estado:          estado,
        estadoDisplay:   estadoDisplay,
        bloqueNombre:    bloqueNombre,
        piso:            piso,
      );
}