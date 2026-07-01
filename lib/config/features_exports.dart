/// Archivo centralizado con todos los imports de features
/// Así se mantiene main.dart limpio y fácil de mantener

// ──────────────────────────────────────────────────────────────────────────────
// AUTH & AUTHENTICATION
// ──────────────────────────────────────────────────────────────────────────────
export 'package:frontend/features/auth/guards/auth_guard.dart';
export 'package:frontend/features/auth/providers/auth_provider.dart';
export 'package:frontend/features/auth/screens/edit_profile_screen.dart';
export 'package:frontend/features/auth/screens/forgot_password_screen.dart';
export 'package:frontend/features/auth/screens/login_screen.dart';
export 'package:frontend/features/auth/screens/profile_screen.dart';
export 'package:frontend/features/auth/screens/register_screen.dart';
export 'package:frontend/features/auth/screens/reset_password_screen.dart';
export 'package:frontend/features/auth/screens/verify_email_screen.dart';

// ──────────────────────────────────────────────────────────────────────────────
// USERS
// ──────────────────────────────────────────────────────────────────────────────
export 'package:frontend/features/users/providers/user_provider.dart';
export 'package:frontend/features/users/screens/user_create_screen.dart';
export 'package:frontend/features/users/screens/user_list_screen.dart';
export 'package:frontend/features/users/screens/user_retrieve_update_screen.dart';

// ──────────────────────────────────────────────────────────────────────────────
// AULAS
// ──────────────────────────────────────────────────────────────────────────────
export 'package:frontend/features/aulas/presentation/providers/aula_provider.dart';
export 'package:frontend/features/aulas/presentation/providers/bloque_provider.dart';
export 'package:frontend/features/aulas/presentation/providers/equipamiento_provider.dart';
export 'package:frontend/features/aulas/presentation/screens/aula_gestion_screen.dart';

// ──────────────────────────────────────────────────────────────────────────────
// DOCENTES
// ──────────────────────────────────────────────────────────────────────────────
export 'package:frontend/features/docentes/presentation/providers/docente_provider.dart';
export 'package:frontend/features/docentes/presentation/screens/docente_gestion_screen.dart';

// ──────────────────────────────────────────────────────────────────────────────
// FICHAS
// ──────────────────────────────────────────────────────────────────────────────
export 'package:frontend/features/ficha/presentation/providers/ficha_provider.dart';
export 'package:frontend/features/ficha/presentation/screens/ficha_gestion_screen.dart';

// ──────────────────────────────────────────────────────────────────────────────
// ALERTAS
// ──────────────────────────────────────────────────────────────────────────────
export 'package:frontend/features/alertas/data/datasources/alerta_remote_datasource.dart';
export 'package:frontend/features/alertas/data/repositories_impl/alerta_repository_impl.dart';
export 'package:frontend/features/alertas/domain/usecases/listar_alertas_usecase.dart';
export 'package:frontend/features/alertas/domain/usecases/marcar_alerta_leida_usecase.dart';
export 'package:frontend/features/alertas/presentation/providers/alertas_provider.dart';
export 'package:frontend/features/alertas/presentation/screens/alertas_screen.dart';

// ──────────────────────────────────────────────────────────────────────────────
// COMPETENCIAS
// ──────────────────────────────────────────────────────────────────────────────
export 'package:frontend/features/competencias/presentation/providers/asignatura_provider.dart';
export 'package:frontend/features/competencias/presentation/providers/competencia_provider.dart';
export 'package:frontend/features/competencias/presentation/providers/rap_provider.dart';
export 'package:frontend/features/competencias/presentation/screens/competencias_gestion_screen.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PLANIFICACIÓN
// ──────────────────────────────────────────────────────────────────────────────
export 'package:frontend/features/planificacion/presentation/providers/planificacion_provider.dart';
export 'package:frontend/features/planificacion/presentation/screens/planificacion_gestion_screen.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PROGRAMA
// ──────────────────────────────────────────────────────────────────────────────
export 'package:frontend/features/programa/presentation/providers/modulo_provider.dart';
export 'package:frontend/features/programa/presentation/providers/programa_provider.dart';
export 'package:frontend/features/programa/presentation/providers/version_provider.dart';
export 'package:frontend/features/programa/presentation/screens/programa_gestion_screen.dart';

// ──────────────────────────────────────────────────────────────────────────────
// REPORTES
// ──────────────────────────────────────────────────────────────────────────────
export 'package:frontend/features/reportes/presentation/providers/novedad_provider.dart';
export 'package:frontend/features/reportes/presentation/providers/reporte_provider.dart';
export 'package:frontend/features/reportes/presentation/screens/reportes_gestion_screen.dart';

// ──────────────────────────────────────────────────────────────────────────────
// NOTIFICACIONES
// ──────────────────────────────────────────────────────────────────────────────
export 'package:frontend/features/notificaciones/data/repositories_impl/notificaciones_repository_impl.dart';
export 'package:frontend/features/notificaciones/presentation/providers/notificaciones_provider.dart';
export 'package:frontend/features/notificaciones/presentation/screens/notificaciones_gestion_screen.dart';

// ──────────────────────────────────────────────────────────────────────────────
// CHATBOT
// ──────────────────────────────────────────────────────────────────────────────
export 'package:frontend/features/chatbot/data/datasources/chatbot_remote_datasource.dart';
export 'package:frontend/features/chatbot/data/repositories_impl/chatbot_repository_impl.dart';
export 'package:frontend/features/chatbot/domain/usecases/clear_conversation_usecase.dart';
export 'package:frontend/features/chatbot/domain/usecases/send_message_usecase.dart';
export 'package:frontend/features/chatbot/presentation/providers/chat_provider.dart';
export 'package:frontend/features/chatbot/presentation/screens/chat_screen.dart';

// ──────────────────────────────────────────────────────────────────────────────
// EXPORTACIÓN
// ──────────────────────────────────────────────────────────────────────────────
export 'package:frontend/features/exportacion/presentation/providers/exportacion_provider.dart';
export 'package:frontend/features/exportacion/presentation/screens/exportacion_gestion_screen.dart';

// ──────────────────────────────────────────────────────────────────────────────
// ANALÍTICA
// ──────────────────────────────────────────────────────────────────────────────
export 'package:frontend/features/analitica/data/datasources/analitica_remote_datasource.dart';
export 'package:frontend/features/analitica/data/repositories_impl/analitica_repository_impl.dart';
export 'package:frontend/features/analitica/domain/usecases/analitica_usecases.dart';
export 'package:frontend/features/analitica/presentation/providers/analitica_provider.dart';
export 'package:frontend/features/analitica/presentation/screens/analitica_gestion_screen.dart';

// ──────────────────────────────────────────────────────────────────────────────
// HORARIOS
// ──────────────────────────────────────────────────────────────────────────────
export 'package:frontend/features/bhorario/presentation/providers/horario_provider.dart';
export 'package:frontend/features/bhorario/presentation/screens/horario_screen.dart';

// ──────────────────────────────────────────────────────────────────────────────
// HOME
// ──────────────────────────────────────────────────────────────────────────────
export 'package:frontend/features/home/providers/home_navigation_provider.dart';
export 'package:frontend/features/home/screens/home_router.dart';
export 'package:frontend/features/home/screens/home_screen.dart';
export 'package:frontend/features/home/widgets/dashboard_view.dart';
export 'package:frontend/features/home/widgets/home_background.dart';
export 'package:frontend/features/home/widgets/home_bottom_nav.dart';
export 'package:frontend/features/home/widgets/home_drawer.dart';
