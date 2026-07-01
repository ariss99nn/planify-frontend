// lib/core/constants/app_roles.dart

class AppRoles {
  static const String estudiante     = 'ESTUDIANTE';
  static const String docente        = 'DOCENTE';
  static const String coordinador    = 'COORDINADOR';
  static const String administrativo = 'ADMINISTRATIVO';

  static const Set<String> managers = {coordinador, administrativo};
  static const Set<String> staff    = {docente, coordinador, administrativo};
}