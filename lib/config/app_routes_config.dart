import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/features_exports.dart';

/// Configuración centralizada de todas las rutas de la aplicación
/// Mantiene la navegación en un solo lugar para fácil mantenimiento
class AppRoutesConfig {
  /// Rutas estáticas (sin parámetros dinámicos)
  /// Se usa en MaterialApp.routes
  static final Map<String, WidgetBuilder> staticRoutes = {
    // ──────────────────────────────────────────────────────────────────
    // AUTH
    // ──────────────────────────────────────────────────────────────────
    '/login': (_) => const LoginScreen(),
    '/register': (_) => const RegisterScreen(),
    '/profile': (_) => const ProfileScreen(),
    '/edit-profile': (_) => const EditProfileScreen(),
    '/forgot-password': (_) => ForgotPasswordScreen(),
    '/reset-password': (_) => ResetPasswordScreen(),
    '/verify-email': (ctx) => VerifyEmailScreen(
      email: ModalRoute.of(ctx)!.settings.arguments as String? ?? '',
    ),

    // ──────────────────────────────────────────────────────────────────
    // HOME
    // ──────────────────────────────────────────────────────────────────
    '/home': (_) => AuthGuard(child: const HomeScreen()),

    // ──────────────────────────────────────────────────────────────────
    // USERS
    // ──────────────────────────────────────────────────────────────────
    '/users': (_) => AuthGuard(child: const UserListScreen()),
    '/users/create': (_) => AuthGuard(child: const UserCreateScreen()),

    // ──────────────────────────────────────────────────────────────────
    // AULAS
    // ──────────────────────────────────────────────────────────────────
    '/aulas': (_) => AuthGuard(child: const AulasGestionScreen()),

    // ──────────────────────────────────────────────────────────────────
    // HORARIOS
    // ──────────────────────────────────────────────────────────────────
    '/horarios': (_) => AuthGuard(child: const HorarioScreen()),

    // ──────────────────────────────────────────────────────────────────
    // DOCENTES
    // ──────────────────────────────────────────────────────────────────
    '/docentes': (_) => AuthGuard(child: const DocenteGestionScreen()),

    // ──────────────────────────────────────────────────────────────────
    // FICHAS
    // ──────────────────────────────────────────────────────────────────
    '/fichas': (_) => AuthGuard(child: const FichaGestionScreen()),

    // ──────────────────────────────────────────────────────────────────
    // ALERTAS
    // ──────────────────────────────────────────────────────────────────
    '/alertas': (ctx) => AuthGuard(
      child: AlertasScreen(
        currentUserId:
            Provider.of<AuthProvider>(ctx, listen: false).user?.id ?? 0,
      ),
    ),

    // ──────────────────────────────────────────────────────────────────
    // COMPETENCIAS
    // ──────────────────────────────────────────────────────────────────
    '/competencias': (ctx) => AuthGuard(
      child: CompetenciasGestionScreen(
        userRole:
            Provider.of<AuthProvider>(ctx, listen: false).user?.rol ?? '',
      ),
    ),

    // ──────────────────────────────────────────────────────────────────
    // PLANIFICACIÓN
    // ──────────────────────────────────────────────────────────────────
    '/planificacion': (_) => AuthGuard(child: const PlanificacionGestionScreen()),

    // ──────────────────────────────────────────────────────────────────
    // PROGRAMAS
    // ──────────────────────────────────────────────────────────────────
    '/programas': (_) => AuthGuard(child: const ProgramaGestionScreen()),

    // ──────────────────────────────────────────────────────────────────
    // REPORTES
    // ──────────────────────────────────────────────────────────────────
    '/reportes': (ctx) => AuthGuard(
      child: ReportesGestionScreen(
        userRole:
            Provider.of<AuthProvider>(ctx, listen: false).user?.rol ?? '',
      ),
    ),

    // ──────────────────────────────────────────────────────────────────
    // EXPORTACIÓN
    // ──────────────────────────────────────────────────────────────────
    '/exportacion': (_) => AuthGuard(child: const ExportacionGestionScreen()),

    // ──────────────────────────────────────────────────────────────────
    // ANALÍTICA
    // ──────────────────────────────────────────────────────────────────
    '/analitica': (_) => AuthGuard(child: const AnaliticaGestionScreen()),

    // ──────────────────────────────────────────────────────────────────
    // NOTIFICACIONES
    // ──────────────────────────────────────────────────────────────────
    '/notificaciones': (_) =>
        AuthGuard(child: const NotificacionesGestionScreen()),

    // ──────────────────────────────────────────────────────────────────
    // CHATBOT
    // ──────────────────────────────────────────────────────────────────
    '/chatbot': (_) => AuthGuard(child: const ChatScreen()),
  };

  /// Rutas dinámicas (con parámetros numéricos)
  /// Se usa en MaterialApp.onGenerateRoute
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final segments = Uri.parse(settings.name ?? '').pathSegments;
    if (segments.isEmpty) return null;

    final s0 = segments[0];
    final s1 = segments.length > 1 ? segments[1] : null;
    final id2 = segments.length > 2 ? int.tryParse(segments[2]) : null;

    // ──────────────────────────────────────────────────────────────────
    // PASSWORD RESET
    // ──────────────────────────────────────────────────────────────────
    if (s0 == 'reset-password') {
      return _wrapInAuthGuard(settings, ResetPasswordScreen());
    }

    // ──────────────────────────────────────────────────────────────────
    // USERS: Editar
    // ──────────────────────────────────────────────────────────────────
    if (s0 == 'users' && s1 == 'edit' && id2 != null) {
      return _wrapInAuthGuard(settings, UserRetrieveUpdateScreen(userId: id2));
    }

    return null;
  }

  /// Envuelve el widget en AuthGuard y lo retorna dentro de MaterialPageRoute
  static MaterialPageRoute<T> _wrapInAuthGuard<T>(
    RouteSettings settings,
    Widget child,
  ) =>
      MaterialPageRoute<T>(
        settings: settings,
        builder: (_) => AuthGuard(child: child),
      );
}
