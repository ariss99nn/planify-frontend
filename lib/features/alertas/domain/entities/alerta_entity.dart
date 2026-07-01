import 'package:equatable/equatable.dart';

enum TipoAlerta { conflicto, disponibilidad, sistema, desconocido }

enum FormatoAlerta { email, sms, app, desconocido }

enum EstadoAlerta { pendiente, enviada, leida, desconocido }

class AlertaEntity extends Equatable {
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

  const AlertaEntity({
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

  // ── Lógica de negocio ───────────────────────────────────────────────────

  /// True si la alerta ya fue leída.
  bool get isLeida => estado == EstadoAlerta.leida;

  /// True si [userId] es el destinatario de esta alerta.
  /// Usado para decidir si el usuario actual puede marcarla como leída.
  bool esDe(int userId) => destinatarioId == userId;

  // ── Inmutabilidad ───────────────────────────────────────────────────────

  AlertaEntity copyWith({
    int? id,
    TipoAlerta? tipo,
    String? tipoDisplay,
    EstadoAlerta? estado,
    String? estadoDisplay,
    FormatoAlerta? formatoAlerta,
    String? formatoDisplay,
    String? descripcion,
    int? destinatarioId,
    String? destinatarioNombre,
    int? bloqueOrigen,
    DateTime? fechaCreacion,
    DateTime? fechaLectura,
  }) {
    return AlertaEntity(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      tipoDisplay: tipoDisplay ?? this.tipoDisplay,
      estado: estado ?? this.estado,
      estadoDisplay: estadoDisplay ?? this.estadoDisplay,
      formatoAlerta: formatoAlerta ?? this.formatoAlerta,
      formatoDisplay: formatoDisplay ?? this.formatoDisplay,
      descripcion: descripcion ?? this.descripcion,
      destinatarioId: destinatarioId ?? this.destinatarioId,
      destinatarioNombre: destinatarioNombre ?? this.destinatarioNombre,
      bloqueOrigen: bloqueOrigen ?? this.bloqueOrigen,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaLectura: fechaLectura ?? this.fechaLectura,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tipo,
        tipoDisplay,
        estado,
        estadoDisplay,
        formatoAlerta,
        formatoDisplay,
        descripcion,
        destinatarioId,
        destinatarioNombre,
        bloqueOrigen,
        fechaCreacion,
        fechaLectura,
      ];
}
