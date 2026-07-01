import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/alerta_entity.dart';

/// Resultado paginado de alertas.
/// Vive en el dominio porque el caso de uso necesita conocer
/// si hay más páginas para implementar scroll infinito.
class AlertaPage {
  final List<AlertaEntity> items;
  final int count;
  final bool hasMore;

  const AlertaPage({
    required this.items,
    required this.count,
    required this.hasMore,
  });
}

/// Parámetros para filtrar alertas.
class AlertaFiltros {
  final String? tipo;
  final String? estado;
  final bool soloNoLeidas;
  final int page;
  final int pageSize;

  const AlertaFiltros({
    this.tipo,
    this.estado,
    this.soloNoLeidas = false,
    this.page = 1,
    this.pageSize = 20,
  });

  AlertaFiltros copyWith({
    String? tipo,
    String? estado,
    bool? soloNoLeidas,
    int? page,
    int? pageSize,
  }) {
    return AlertaFiltros(
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      soloNoLeidas: soloNoLeidas ?? this.soloNoLeidas,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

/// Contrato del repositorio de alertas.
/// Solo el dominio y la presentación dependen de esta interfaz.
/// La capa de datos la implementa — nunca al revés.
abstract interface class AlertaRepository {
  /// Retorna una página de alertas según los filtros dados.
  Future<Either<Failure, AlertaPage>> listar(AlertaFiltros filtros);

  /// Marca la alerta [alertaId] como leída.
  /// Retorna la entidad actualizada o un [Failure].
  Future<Either<Failure, AlertaEntity>> marcarLeida(int alertaId);

  /// Crea una alerta individual.
  Future<Either<Failure, AlertaEntity>> crear({
    required String tipo,
    required String descripcion,
    required String formatoAlerta,
    int? destinatario,
    int? bloqueOrigen,
  });

  /// Crea alertas masivas para todos los usuarios de un rol.
  Future<Either<Failure, List<AlertaEntity>>> crearPorRol({
    required String tipo,
    required String descripcion,
    required String formatoAlerta,
    required String destinatarioRol,
    int? bloqueOrigen,
  });
}
