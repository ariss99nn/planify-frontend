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
};
