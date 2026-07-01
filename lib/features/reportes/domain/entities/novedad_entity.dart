enum NovedadTipo {
  fichaSinPlan,
  docenteSobrecargado,
  aulaConflicto,
  avanceBajo,
  estudianteEnRiesgo,
  planSinDocente,
  fichaSinHorario,
  otra,
}

extension NovedadTipoX on NovedadTipo {
  String get value {
    switch (this) {
      case NovedadTipo.fichaSinPlan:
        return 'FICHA_SIN_PLAN';
      case NovedadTipo.docenteSobrecargado:
        return 'DOCENTE_SOBRECARGADO';
      case NovedadTipo.aulaConflicto:
        return 'AULA_CONFLICTO';
      case NovedadTipo.avanceBajo:
        return 'AVANCE_BAJO';
      case NovedadTipo.estudianteEnRiesgo:
        return 'ESTUDIANTE_EN_RIESGO';
      case NovedadTipo.planSinDocente:
        return 'PLAN_SIN_DOCENTE';
      case NovedadTipo.fichaSinHorario:
        return 'FICHA_SIN_HORARIO';
      case NovedadTipo.otra:
        return 'OTRA';
    }
  }

  String get label {
    switch (this) {
      case NovedadTipo.fichaSinPlan:
        return 'Ficha sin plan aprobado';
      case NovedadTipo.docenteSobrecargado:
        return 'Docente sobrecargado';
      case NovedadTipo.aulaConflicto:
        return 'Aula con conflicto';
      case NovedadTipo.avanceBajo:
        return 'Avance curricular bajo';
      case NovedadTipo.estudianteEnRiesgo:
        return 'Estudiante en riesgo';
      case NovedadTipo.planSinDocente:
        return 'Competencia sin docente asignado';
      case NovedadTipo.fichaSinHorario:
        return 'Ficha sin horario generado';
      case NovedadTipo.otra:
        return 'Otra';
    }
  }

  static NovedadTipo fromValue(String raw) {
    return NovedadTipo.values.firstWhere(
      (t) => t.value == raw,
      orElse: () => NovedadTipo.otra,
    );
  }
}

enum NovedadPrioridad { alta, media, baja }

extension NovedadPrioridadX on NovedadPrioridad {
  int get value {
    switch (this) {
      case NovedadPrioridad.alta:
        return 1;
      case NovedadPrioridad.media:
        return 2;
      case NovedadPrioridad.baja:
        return 3;
    }
  }

  String get label {
    switch (this) {
      case NovedadPrioridad.alta:
        return 'Alta';
      case NovedadPrioridad.media:
        return 'Media';
      case NovedadPrioridad.baja:
        return 'Baja';
    }
  }

  static NovedadPrioridad fromValue(int raw) {
    switch (raw) {
      case 1:
        return NovedadPrioridad.alta;
      case 3:
        return NovedadPrioridad.baja;
      default:
        return NovedadPrioridad.media;
    }
  }
}

class NovedadEntity {
  final int id;
  final NovedadTipo tipo;
  final String tipoDisplay;
  final NovedadPrioridad prioridad;
  final String prioridadDisplay;
  final String titulo;
  final String descripcion;
  final bool generadaPorSistema;
  final int? generadaPor;
  final bool atendida;
  final int? atendidaPor;
  final String? atendidaPorNombre;
  final DateTime? fechaAtencion;
  final String notaAtencion;
  final DateTime fechaGeneracion;
  final DateTime? fechaExpiracion;
  final bool estaVigente;

  const NovedadEntity({
    required this.id,
    required this.tipo,
    required this.tipoDisplay,
    required this.prioridad,
    required this.prioridadDisplay,
    required this.titulo,
    required this.descripcion,
    required this.generadaPorSistema,
    this.generadaPor,
    required this.atendida,
    this.atendidaPor,
    this.atendidaPorNombre,
    this.fechaAtencion,
    required this.notaAtencion,
    required this.fechaGeneracion,
    this.fechaExpiracion,
    required this.estaVigente,
  });

  NovedadEntity copyWith({
    bool? atendida,
    int? atendidaPor,
    String? atendidaPorNombre,
    DateTime? fechaAtencion,
    String? notaAtencion,
  }) {
    return NovedadEntity(
      id: id,
      tipo: tipo,
      tipoDisplay: tipoDisplay,
      prioridad: prioridad,
      prioridadDisplay: prioridadDisplay,
      titulo: titulo,
      descripcion: descripcion,
      generadaPorSistema: generadaPorSistema,
      generadaPor: generadaPor,
      atendida: atendida ?? this.atendida,
      atendidaPor: atendidaPor ?? this.atendidaPor,
      atendidaPorNombre: atendidaPorNombre ?? this.atendidaPorNombre,
      fechaAtencion: fechaAtencion ?? this.fechaAtencion,
      notaAtencion: notaAtencion ?? this.notaAtencion,
      fechaGeneracion: fechaGeneracion,
      fechaExpiracion: fechaExpiracion,
      estaVigente: estaVigente,
    );
  }
}

class NovedadCreateInput {
  final NovedadTipo tipo;
  final NovedadPrioridad prioridad;
  final String titulo;
  final String descripcion;
  final DateTime? fechaExpiracion;

  const NovedadCreateInput({
    required this.tipo,
    required this.prioridad,
    required this.titulo,
    required this.descripcion,
    this.fechaExpiracion,
  });

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo.value,
      'prioridad': prioridad.value,
      'titulo': titulo,
      'descripcion': descripcion,
      if (fechaExpiracion != null)
        'fecha_expiracion': fechaExpiracion!.toUtc().toIso8601String(),
    };
  }
}
