import '../../domain/entities/exportacion_enums.dart';

class FiltroCampo {
  const FiltroCampo({
    required this.key,
    required this.label,
    this.opciones,
    this.hint,
  });

  final String                       key;
  final String                       label;
  final List<MapEntry<String, String>>? opciones;
  final String?                      hint;

  bool get esSelect => opciones != null;
}

const Map<TipoExportacion, List<FiltroCampo>> kFiltrosPorModulo = {
  TipoExportacion.fichas: [
    FiltroCampo(key: 'etapa', label: 'Etapa', opciones: [
      MapEntry('', 'Todas las etapas'),
      MapEntry('LECTIVA', 'Lectiva'),
      MapEntry('PRODUCTIVA', 'Productiva'),
    ]),
    FiltroCampo(key: 'jornada', label: 'Jornada', opciones: [
      MapEntry('', 'Todas las jornadas'),
      MapEntry('MANANA', 'Mañana'),
      MapEntry('TARDE', 'Tarde'),
      MapEntry('NOCHE', 'Noche'),
      MapEntry('MIXTA', 'Mixta'),
    ]),
  ],
  TipoExportacion.docentes: [
    FiltroCampo(
      key:  'especialidad',
      label: 'Especialidad',
      hint: 'Ej: sistemas, diseño…',
    ),
  ],
  TipoExportacion.horarios: [
    FiltroCampo(key: 'dia_semana', label: 'Día de la semana', opciones: [
      MapEntry('', 'Todos los días'),
      MapEntry('LUNES', 'Lunes'),
      MapEntry('MARTES', 'Martes'),
      MapEntry('MIERCOLES', 'Miércoles'),
      MapEntry('JUEVES', 'Jueves'),
      MapEntry('VIERNES', 'Viernes'),
      MapEntry('SABADO', 'Sábado'),
    ]),
    FiltroCampo(key: 'jornada', label: 'Jornada', opciones: [
      MapEntry('', 'Todas las jornadas'),
      MapEntry('MANANA', 'Mañana'),
      MapEntry('TARDE', 'Tarde'),
      MapEntry('NOCHE', 'Noche'),
      MapEntry('MIXTA', 'Mixta'),
    ]),
  ],
  TipoExportacion.estudiantes: [
    FiltroCampo(key: 'activo', label: 'Estado', opciones: [
      MapEntry('', 'Todos'),
      MapEntry('true', 'Activos'),
      MapEntry('false', 'Inactivos'),
    ]),
    FiltroCampo(
      key:  'ficha_id',
      label: 'ID de ficha',
      hint: 'Ej: 12',
    ),
    FiltroCampo(
      key:  'programa_id',
      label: 'ID de programa',
      hint: 'Ej: 3',
    ),
  ],
  TipoExportacion.aulas: [
    FiltroCampo(key: 'estado', label: 'Estado', opciones: [
      MapEntry('', 'Todos los estados'),
      MapEntry('ACTIVA', 'Activa'),
      MapEntry('MANTENIMIENTO', 'Mantenimiento'),
      MapEntry('INACTIVA', 'Inactiva'),
    ]),
    FiltroCampo(
      key:  'tipo_aula',
      label: 'Tipo de aula',
      hint: 'Ej: laboratorio, teorica…',
    ),
  ],
  TipoExportacion.planes: [
    FiltroCampo(
      key:  'estado',
      label: 'Estado del plan',
      hint: 'Ej: APROBADO, PENDIENTE…',
    ),
    FiltroCampo(
      key:  'ficha_id',
      label: 'ID de ficha',
      hint: 'Ej: 12',
    ),
  ],
  TipoExportacion.competencias: [
    FiltroCampo(
      key:  'programa_id',
      label: 'ID de programa',
      hint: 'Ej: 3',
    ),
  ],
  TipoExportacion.analitica: [
    FiltroCampo(
      key:  'fecha_inicio',
      label: 'Fecha inicio',
      hint: 'AAAA-MM-DD',
    ),
    FiltroCampo(
      key:  'fecha_fin',
      label: 'Fecha fin',
      hint: 'AAAA-MM-DD',
    ),
  ],
  // TipoExportacion.completa no tiene filtros: exporta todas las tablas
  // completas, una hoja por módulo.
};
