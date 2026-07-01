import '../../domain/entities/exportacion_enums.dart';
import '../../domain/entities/registro_exportacion_entity.dart';

class RegistroExportacionModel extends RegistroExportacionEntity {
  const RegistroExportacionModel({
    required super.id,
    required super.usuario,
    required super.usuarioNombre,
    required super.tipo,
    required super.tipoDisplay,
    required super.formato,
    required super.formatoDisplay,
    required super.filtros,
    required super.registrosExportados,
    super.ipOrigen,
    required super.fecha,
  });

  factory RegistroExportacionModel.fromJson(Map<String, dynamic> json) =>
      RegistroExportacionModel(
        id:                  json['id']                   as int,
        usuario:             json['usuario']              as int,
        usuarioNombre:       json['usuario_nombre']       as String? ?? '',
        tipo:                json['tipo']                 as String,
        tipoDisplay:         json['tipo_display']         as String? ?? '',
        formato:             json['formato']              as String,
        formatoDisplay:      json['formato_display']      as String? ?? '',
        filtros:            (json['filtros']              as Map<String, dynamic>?) ?? {},
        registrosExportados: json['registros_exportados'] as int? ?? 0,
        ipOrigen:            json['ip_origen']            as String?,
        fecha:               DateTime.parse(json['fecha'] as String),
      );
}
