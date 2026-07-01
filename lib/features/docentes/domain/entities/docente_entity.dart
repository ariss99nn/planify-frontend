// lib/features/docentes/domain/entities/docente_entity.dart

class DocenteEntity {
  final int     id;
  final int?    userId;
  final String  nombre;
  final String  email;
  final String  especialidad;
  final int     horasMaxSemanales;
  final bool    permiteHorasExtra;
  final int     horasExtraAutorizadas;
  final int?    horasMaxEfectivas;
  final double? horasAsignadasSemana;
  final bool?   estaSobrecargado;
  final bool    estado;
  final String? imagenUrl;
  final String? avatarUrl;

  const DocenteEntity({
    required this.id,
    this.userId,
    required this.nombre,
    required this.email,
    required this.especialidad,
    required this.horasMaxSemanales,
    required this.permiteHorasExtra,
    required this.horasExtraAutorizadas,
    this.horasMaxEfectivas,
    this.horasAsignadasSemana,
    this.estaSobrecargado,
    required this.estado,
    this.imagenUrl,
    this.avatarUrl,
  });

  String get iniciales {
    final parts = nombre.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  int get horasMaxEfectivasLocal =>
      horasMaxEfectivas ??
      (permiteHorasExtra
          ? horasMaxSemanales + horasExtraAutorizadas
          : horasMaxSemanales);
}
