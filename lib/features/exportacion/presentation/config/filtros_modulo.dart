import '../../domain/entities/exportacion_enums.dart';

class FiltroCampo {
  const FiltroCampo({
    required this.key,
    required this.label,
    this.opciones,
    this.hint,
  });

  final String                          key;
  final String                          label;
  final List<MapEntry<String, String>>? opciones;
  final String?                         hint;

  bool get esSelect => opciones != null;
}

// Filtros comunes reutilizados por varios módulos que cuelgan de Programa
// (Fichas, Estudiantes, Horarios, Planes, Competencias). Reemplazan los
// antiguos filtros por ID crudo ("ID de ficha", "ID de programa") por
// búsqueda humana y por el tipo de formación / nivel del programa.
const _filtroTipoFormacion = FiltroCampo(
  key: 'tipo_formacion',
  label: 'Tipo de formación',
  opciones: [
    MapEntry('', 'Todos los tipos'),
    MapEntry('POR_OFERTA', 'Por Oferta'),
    MapEntry('CADENA_FORMACION', 'Cadena de Formación'),
    MapEntry('OTRO', 'Otro'),
  ],
);

const _filtroNivelPrograma = FiltroCampo(
  key: 'nivel_programa',
  label: 'Nivel del programa',
  opciones: [
    MapEntry('', 'Todos los niveles'),
    MapEntry('TECNICO', 'Técnico'),
    MapEntry('TECNOLOGIA', 'Tecnología'),
    MapEntry('CURSO_CORTO', 'Curso Corto'),
  ],
);

const _filtroProgramaNombre = FiltroCampo(
  key:  'programa',
  label: 'Programa',
  hint: 'Buscar por nombre, ej: Análisis y Desarrollo…',
);

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
    FiltroCampo(key: 'cadena_formacion', label: 'Cadena de formación', opciones: [
      MapEntry('', 'Todas'),
      MapEntry('true', 'En cadena de formación'),
      MapEntry('false', 'No aplica'),
    ]),
    _filtroTipoFormacion,
    _filtroNivelPrograma,
    _filtroProgramaNombre,
    FiltroCampo(
      key:  'codigo_ficha',
      label: 'Código de ficha',
      hint: 'Ej: 2758901',
    ),
  ],
  TipoExportacion.estudiantes: [
    FiltroCampo(key: 'activo', label: 'Estado', opciones: [
      MapEntry('', 'Todos'),
      MapEntry('true', 'Activos'),
      MapEntry('false', 'Inactivos'),
    ]),
    FiltroCampo(key: 'motivo_retiro', label: 'Motivo de retiro', opciones: [
      MapEntry('', 'Cualquiera'),
      MapEntry('DESERCION', 'Deserción'),
      MapEntry('RETIRO_VOLUNTARIO', 'Retiro voluntario'),
      MapEntry('CANCELADO', 'Cancelado por rendimiento'),
      MapEntry('GRADUADO', 'Graduado'),
      MapEntry('REASIGNADO', 'Reasignado a otra ficha'),
    ]),
    FiltroCampo(key: 'es_cadena', label: 'Ingreso por cadena', opciones: [
      MapEntry('', 'Todos'),
      MapEntry('true', 'Sí'),
      MapEntry('false', 'No'),
    ]),
    FiltroCampo(key: 'etapa_ficha', label: 'Etapa de la ficha', opciones: [
      MapEntry('', 'Todas las etapas'),
      MapEntry('LECTIVA', 'Lectiva'),
      MapEntry('PRODUCTIVA', 'Productiva'),
    ]),
    FiltroCampo(key: 'jornada_ficha', label: 'Jornada de la ficha', opciones: [
      MapEntry('', 'Todas las jornadas'),
      MapEntry('MANANA', 'Mañana'),
      MapEntry('TARDE', 'Tarde'),
      MapEntry('NOCHE', 'Noche'),
      MapEntry('MIXTA', 'Mixta'),
    ]),
    _filtroTipoFormacion,
    _filtroNivelPrograma,
    _filtroProgramaNombre,
    FiltroCampo(
      key:  'ficha_codigo',
      label: 'Código de ficha',
      hint: 'Ej: 2758901',
    ),
  ],
  TipoExportacion.docentes: [
    FiltroCampo(key: 'estado', label: 'Estado', opciones: [
      MapEntry('', 'Solo activos'),
      MapEntry('true', 'Activos'),
      MapEntry('false', 'Inactivos'),
    ]),
    FiltroCampo(key: 'permite_horas_extra', label: 'Horas extra', opciones: [
      MapEntry('', 'Todos'),
      MapEntry('true', 'Autorizadas'),
      MapEntry('false', 'No autorizadas'),
    ]),
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
    _filtroTipoFormacion,
    _filtroProgramaNombre,
    FiltroCampo(
      key:  'ficha_codigo',
      label: 'Código de ficha',
      hint: 'Ej: 2758901',
    ),
    FiltroCampo(
      key:  'docente',
      label: 'Docente',
      hint: 'Buscar por nombre…',
    ),
  ],
  TipoExportacion.aulas: [
    FiltroCampo(key: 'estado', label: 'Estado', opciones: [
      MapEntry('', 'Todos los estados'),
      MapEntry('ACT', 'Activa'),
      MapEntry('MANT', 'Mantenimiento'),
      MapEntry('INAC', 'Inactiva'),
    ]),
    FiltroCampo(key: 'tipo_aula', label: 'Tipo de aula', opciones: [
      MapEntry('', 'Todos los tipos'),
      MapEntry('LAB', 'Laboratorio'),
      MapEntry('TEO', 'Teórica'),
      MapEntry('SIS', 'Sistemas de Información'),
      MapEntry('OTR', 'Otro'),
    ]),
    FiltroCampo(
      key:  'bloque',
      label: 'Bloque',
      hint: 'Buscar por nombre del bloque…',
    ),
    FiltroCampo(
      key:  'capacidad_minima',
      label: 'Capacidad mínima',
      hint: 'Ej: 20',
    ),
  ],
  TipoExportacion.planes: [
    FiltroCampo(key: 'estado', label: 'Estado del plan', opciones: [
      MapEntry('', 'Todos los estados'),
      MapEntry('BORRADOR', 'Borrador'),
      MapEntry('EN_REVISION', 'En revisión'),
      MapEntry('APROBADO', 'Aprobado'),
      MapEntry('EN_EJECUCION', 'En ejecución'),
      MapEntry('CERRADO', 'Cerrado'),
      MapEntry('RECHAZADO', 'Rechazado'),
    ]),
    _filtroTipoFormacion,
    _filtroProgramaNombre,
    FiltroCampo(
      key:  'ficha_codigo',
      label: 'Código de ficha',
      hint: 'Ej: 2758901',
    ),
  ],
  TipoExportacion.competencias: [
    FiltroCampo(key: 'tipo', label: 'Tipo de competencia', opciones: [
      MapEntry('', 'Todas'),
      MapEntry('PRINCIPAL', 'Principal'),
      MapEntry('TRANSVERSAL', 'Transversal'),
    ]),
    FiltroCampo(key: 'es_induccion', label: 'Inducción', opciones: [
      MapEntry('', 'Todas'),
      MapEntry('true', 'Solo inducción'),
      MapEntry('false', 'Excluir inducción'),
    ]),
    _filtroTipoFormacion,
    _filtroNivelPrograma,
    _filtroProgramaNombre,
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
