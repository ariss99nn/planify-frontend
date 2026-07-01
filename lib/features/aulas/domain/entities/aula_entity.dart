// lib/features/aulas/domain/entities/aula_entity.dart

import 'bloque_entity.dart';
import 'equipamiento_entity.dart';

class AulaEntity {
  final int id;
  final String codigoAula;
  final int capacidad;
  final String tipoAula;
  final String tipoAulaDisplay;
  final String estado;
  final String estadoDisplay;
  final BloqueEntity bloque;
  final int piso;
  final String descripcion;
  final String? imagenUrl;
  final List<EquipamientoEntity> equipamiento;

  const AulaEntity({
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
}

class AulaResumenEntity {
  final int id;
  final String codigoAula;
  final int capacidad;
  final String tipoAula;
  final String tipoAulaDisplay;
  final String estado;
  final String estadoDisplay;
  final String bloqueNombre;
  final int piso;

  const AulaResumenEntity({
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
}