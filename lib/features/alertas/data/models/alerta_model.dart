import '../../domain/entities/alerta_entity.dart';

/// DTO de transporte — solo responsable de mapear JSON a objetos Dart
/// y de convertirse a [AlertaEntity].
/// No contiene lógica de negocio.
class AlertaModel {
  final int id;
  final TipoAlerta tipo;
  final String tipoDisplay;
  final EstadoAlerta estado;
  final String estadoDisplay;
  final FormatoAlerta formatoAlerta;
  final String formatoDisplay;
  final String descripcion;
  final int? destinatarioId;
  final String? destinatarioNombre;
  final int? bloqueOrigen;
  final DateTime fechaCreacion;
  final DateTime? fechaLectura;

  const AlertaModel({
    required this.id,
    required this.tipo,
    required this.tipoDisplay,
    required this.estado,
    required this.estadoDisplay,
    required this.formatoAlerta,
    required this.formatoDisplay,
    required this.descripcion,
    this.destinatarioId,
    this.destinatarioNombre,
    this.bloqueOrigen,
    required this.fechaCreacion,
    this.fechaLectura,
  });

  // ── fromJson ─────────────────────────────────────────────────────────────

  factory AlertaModel.fromJson(Map<String, dynamic> json) {
    return AlertaModel(
      id: json['id'] as int,
      tipo: _parseTipo(json['tipo'] as String? ?? ''),
      tipoDisplay: json['tipo_display'] as String? ?? '',
      estado: _parseEstado(json['estado'] as String? ?? ''),
      estadoDisplay: json['estado_display'] as String? ?? '',
      formatoAlerta: _parseFormato(json['formato_alerta'] as String? ?? ''),
      formatoDisplay: json['formato_display'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      destinatarioId: json['destinatario'] as int?,
      destinatarioNombre: json['destinatario_nombre'] as String?,
      bloqueOrigen: json['bloque_origen'] as int?,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      fechaLectura: json['fecha_lectura'] != null
          ? DateTime.parse(json['fecha_lectura'] as String)
          : null,
    );
  }

  // ── toJson ────────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': _tipoToString(tipo),
        'tipo_display': tipoDisplay,
        'estado': _estadoToString(estado),
        'estado_display': estadoDisplay,
        'formato_alerta': _formatoToString(formatoAlerta),
        'formato_display': formatoDisplay,
        'descripcion': descripcion,
        if (destinatarioId != null) 'destinatario': destinatarioId,
        if (destinatarioNombre != null) 'destinatario_nombre': destinatarioNombre,
        if (bloqueOrigen != null) 'bloque_origen': bloqueOrigen,
        'fecha_creacion': fechaCreacion.toIso8601String(),
        if (fechaLectura != null) 'fecha_lectura': fechaLectura!.toIso8601String(),
      };

  // ── Mapper a Entity ───────────────────────────────────────────────────────

  AlertaEntity toEntity() => AlertaEntity(
        id: id,
        tipo: tipo,
        tipoDisplay: tipoDisplay,
        estado: estado,
        estadoDisplay: estadoDisplay,
        formatoAlerta: formatoAlerta,
        formatoDisplay: formatoDisplay,
        descripcion: descripcion,
        destinatarioId: destinatarioId,
        destinatarioNombre: destinatarioNombre,
        bloqueOrigen: bloqueOrigen,
        fechaCreacion: fechaCreacion,
        fechaLectura: fechaLectura,
      );

  // ── Parsers seguros ───────────────────────────────────────────────────────
  // Usan `desconocido` como fallback para que valores nuevos del backend
  // no rompan la app en producción.

  static TipoAlerta _parseTipo(String raw) => switch (raw) {
        'CONFLICTO' => TipoAlerta.conflicto,
        'DISPONIBILIDAD' => TipoAlerta.disponibilidad,
        'SISTEMA' => TipoAlerta.sistema,
        _ => TipoAlerta.desconocido,
      };

  static EstadoAlerta _parseEstado(String raw) => switch (raw) {
        'PENDIENTE' => EstadoAlerta.pendiente,
        'ENVIADA' => EstadoAlerta.enviada,
        'LEIDA' => EstadoAlerta.leida,
        _ => EstadoAlerta.desconocido,
      };

  static FormatoAlerta _parseFormato(String raw) => switch (raw) {
        'EMAIL' => FormatoAlerta.email,
        'SMS' => FormatoAlerta.sms,
        'APP' => FormatoAlerta.app,
        _ => FormatoAlerta.desconocido,
      };

  static String _tipoToString(TipoAlerta t) => switch (t) {
        TipoAlerta.conflicto => 'CONFLICTO',
        TipoAlerta.disponibilidad => 'DISPONIBILIDAD',
        TipoAlerta.sistema => 'SISTEMA',
        TipoAlerta.desconocido => '',
      };

  static String _estadoToString(EstadoAlerta e) => switch (e) {
        EstadoAlerta.pendiente => 'PENDIENTE',
        EstadoAlerta.enviada => 'ENVIADA',
        EstadoAlerta.leida => 'LEIDA',
        EstadoAlerta.desconocido => '',
      };

  static String _formatoToString(FormatoAlerta f) => switch (f) {
        FormatoAlerta.email => 'EMAIL',
        FormatoAlerta.sms => 'SMS',
        FormatoAlerta.app => 'APP',
        FormatoAlerta.desconocido => '',
      };
}
