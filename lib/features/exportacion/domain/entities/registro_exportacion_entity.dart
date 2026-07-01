import 'exportacion_enums.dart';

class RegistroExportacionEntity {
  final int                  id;
  final int                  usuario;
  final String               usuarioNombre;
  final String               tipo;
  final String               tipoDisplay;
  final String               formato;
  final String               formatoDisplay;
  final Map<String, dynamic> filtros;
  final int                  registrosExportados;
  final String?              ipOrigen;
  final DateTime             fecha;

  const RegistroExportacionEntity({
    required this.id,
    required this.usuario,
    required this.usuarioNombre,
    required this.tipo,
    required this.tipoDisplay,
    required this.formato,
    required this.formatoDisplay,
    required this.filtros,
    required this.registrosExportados,
    this.ipOrigen,
    required this.fecha,
  });

  TipoExportacion?    get tipoEnum    => TipoExportacion.fromValue(tipo);
  FormatoExportacion? get formatoEnum => FormatoExportacion.fromValue(formato);
}
