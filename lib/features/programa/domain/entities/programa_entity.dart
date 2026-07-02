// lib/features/programa/domain/entities/programa_entity.dart
import 'version_programa_entity.dart';

enum ProgramaNivel {
  tecnico('TECNICO', 'Técnico'),
  tecnologia('TECNOLOGIA', 'Tecnología'),
  cursoCorto('CURSO_CORTO', 'Curso Corto');

  final String value;
  final String label;
  const ProgramaNivel(this.value, this.label);

  static ProgramaNivel fromValue(String value) => values.firstWhere(
        (e) => e.value == value,
        orElse: () => ProgramaNivel.tecnico,
      );
}

enum ProgramaEstado {
  activo('ACTIVO', 'Activo'),
  inactivo('INACTIVO', 'Inactivo'),
  enRevision('EN_REVISION', 'En revisión');

  final String value;
  final String label;
  const ProgramaEstado(this.value, this.label);

  static ProgramaEstado fromValue(String value) => values.firstWhere(
        (e) => e.value == value,
        orElse: () => ProgramaEstado.activo,
      );
}

enum ProgramaTipoFormacion {
  porOferta('POR_OFERTA', 'Por Oferta'),
  cadenaFormacion('CADENA_FORMACION', 'Cadena de Formación'),
  otro('OTRO', 'Otro');

  final String value;
  final String label;
  const ProgramaTipoFormacion(this.value, this.label);

  static ProgramaTipoFormacion fromValue(String value) => values.firstWhere(
        (e) => e.value == value,
        orElse: () => ProgramaTipoFormacion.porOferta,
      );
}

/// Valores de referencia aproximados por nivel, para autocompletar el
/// formulario de creación/edición de programas.
///
/// IMPORTANTE: debe reflejar `Programa.PRESETS` en el backend
/// (programa/models/programa_model.py). La validación real (la que no se
/// puede saltar) vive en el backend; esto es solo para agilizar la carga
/// y evitar que el usuario tenga que recordar las cifras de memoria.
class ProgramaPreset {
  /// Trimestres lectivos sugeridos (trimestres_totales).
  final int trimestresTotales;
  final int? horasLectivas;
  final int? horasPracticas;
  final int? horasLectivasMin;
  final int? horasLectivasMax;
  final int? duracionMesesAprox;
  final bool permiteCadenaFormacion;
  final String descripcion;

  const ProgramaPreset({
    required this.trimestresTotales,
    this.horasLectivas,
    this.horasPracticas,
    this.horasLectivasMin,
    this.horasLectivasMax,
    this.duracionMesesAprox,
    required this.permiteCadenaFormacion,
    required this.descripcion,
  });

  static const Map<ProgramaNivel, ProgramaPreset> byNivel = {
    ProgramaNivel.tecnologia: ProgramaPreset(
      trimestresTotales: 7,
      horasLectivas: 3120,
      horasPracticas: 864,
      duracionMesesAprox: 27,
      permiteCadenaFormacion: true,
      descripcion:
          '≈ 9 trimestres (7 lectivos + 2 productivos) · ≈ 27 meses en total.',
    ),
    ProgramaNivel.tecnico: ProgramaPreset(
      trimestresTotales: 2,
      duracionMesesAprox: 12,
      permiteCadenaFormacion: false,
      descripcion: '≈ 6 meses lectivos + 6 meses productivos (≈ 12 meses).',
    ),
    ProgramaNivel.cursoCorto: ProgramaPreset(
      trimestresTotales: 1,
      horasLectivasMin: 40,
      horasLectivasMax: 80,
      horasPracticas: 0,
      permiteCadenaFormacion: false,
      descripcion: 'Entre 40 y 80 horas lectivas · sin etapa productiva.',
    ),
  };
}

/// Resumen de programa (coincide con ProgramaListSerializer).
class ProgramaResumenEntity {
  final int id;
  final String nombre;
  final ProgramaNivel nivel;
  final String nivelDisplay;
  final ProgramaEstado estado;
  final String estadoDisplay;
  final ProgramaTipoFormacion tipoFormacion;
  final String tipoFormacionDisplay;
  final int horasLectivas;
  final int horasPracticas;
  final int totalHoras;
  final int totalVersiones;

  const ProgramaResumenEntity({
    required this.id,
    required this.nombre,
    required this.nivel,
    required this.nivelDisplay,
    required this.estado,
    required this.estadoDisplay,
    required this.tipoFormacion,
    required this.tipoFormacionDisplay,
    required this.horasLectivas,
    required this.horasPracticas,
    required this.totalHoras,
    required this.totalVersiones,
  });

  /// Reconstruye una fila de lista a partir del detalle completo, útil
  /// tras crear/actualizar para mantener la lista local sincronizada sin
  /// tener que pegarle de nuevo al endpoint de lista.
  factory ProgramaResumenEntity.fromDetail(ProgramaEntity p) {
    return ProgramaResumenEntity(
      id: p.id,
      nombre: p.nombre,
      nivel: p.nivel,
      nivelDisplay: p.nivelDisplay,
      estado: p.estado,
      estadoDisplay: p.estadoDisplay,
      tipoFormacion: p.tipoFormacion,
      tipoFormacionDisplay: p.tipoFormacionDisplay,
      horasLectivas: p.horasLectivas,
      horasPracticas: p.horasPracticas,
      totalHoras: p.totalHoras,
      totalVersiones: p.versiones.length,
    );
  }
}

/// Detalle de programa (coincide con ProgramaDetailSerializer).
class ProgramaEntity {
  final int id;
  final String nombre;
  final String descripcion;
  final ProgramaNivel nivel;
  final String nivelDisplay;
  final int horasLectivas;
  final int horasPracticas;
  final int totalHoras;
  final ProgramaEstado estado;
  final String estadoDisplay;
  final int trimestresTotales;
  final ProgramaTipoFormacion tipoFormacion;
  final String tipoFormacionDisplay;
  final int? trimestresCadena;
  final List<VersionResumenEntity> versiones;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProgramaEntity({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.nivel,
    required this.nivelDisplay,
    required this.horasLectivas,
    required this.horasPracticas,
    required this.totalHoras,
    required this.estado,
    required this.estadoDisplay,
    required this.trimestresTotales,
    required this.tipoFormacion,
    required this.tipoFormacionDisplay,
    required this.trimestresCadena,
    required this.versiones,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Refleja Programa.clean(): solo aplica/requiere trimestres_cadena
  /// cuando el tipo de formación es cadena de formación.
  bool get esCadenaFormacion =>
      tipoFormacion == ProgramaTipoFormacion.cadenaFormacion;
}
