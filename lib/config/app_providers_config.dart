import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../config/features_exports.dart';

/// Configuración centralizada de todos los providers de la aplicación
/// Mantiene la lógica de inyección de dependencias en un solo lugar
class AppProvidersConfig {
  /// URL base del API
  final String apiUrl;

  /// URL base del WebSocket
  final String wsUrl;

  AppProvidersConfig({
    required this.apiUrl,
    required this.wsUrl,
  });

  /// Retorna la lista de providers configurados y listos para usar
  List<dynamic> build() {
    // ────────────────────────────────────────────────────────────────────
    // Instancias compartidas para inyección de dependencias
    // ────────────────────────────────────────────────────────────────────
    final chatbotRepo = ChatbotRepositoryImpl(
      ChatbotRemoteDatasourceImpl(
        client: http.Client(),
        baseUrl: apiUrl.isNotEmpty ? apiUrl : 'http://10.0.2.2:8000',
      ),
    );

    final analiticaRepo = AnaliticaRepositoryImpl(
      AnaliticaRemoteDataSourceImpl(),
    );

    final alertaRepo = AlertaRepositoryImpl(
      AlertaRemoteDatasourceImpl(),
    );

    return [
      // ────────────────────────────────────────────────────────────────
      // AUTH & USERS
      // ────────────────────────────────────────────────────────────────
      ChangeNotifierProvider(
        create: (_) => AuthProvider()..checkAuth(),
      ),
      ChangeNotifierProvider(
        create: (_) => UserProvider(),
      ),

      // ────────────────────────────────────────────────────────────────
      // HOME NAVIGATION
      // ────────────────────────────────────────────────────────────────
      ChangeNotifierProvider(
        create: (_) => HomeNavigationProvider(),
      ),

      // ────────────────────────────────────────────────────────────────
      // AULAS
      // ────────────────────────────────────────────────────────────────
      ChangeNotifierProvider(
        create: (_) => AulaProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => BloqueProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => EquipamientoProvider(),
      ),

      // ────────────────────────────────────────────────────────────────
      // DOCENTES
      // ────────────────────────────────────────────────────────────────
      ChangeNotifierProvider(
        create: (_) => DocenteProvider(),
      ),

      // ────────────────────────────────────────────────────────────────
      // FICHAS
      // ────────────────────────────────────────────────────────────────
      ChangeNotifierProvider(
        create: (_) => FichaProvider(),
      ),

      // ────────────────────────────────────────────────────────────────
      // ALERTAS
      // ────────────────────────────────────────────────────────────────
      ChangeNotifierProvider(
        create: (_) => AlertasProvider(
          listar: ListarAlertasUseCase(alertaRepo),
          marcarLeida: MarcarAlertaLeidaUseCase(alertaRepo),
        ),
      ),

      // ────────────────────────────────────────────────────────────────
      // COMPETENCIAS
      // ────────────────────────────────────────────────────────────────
      ChangeNotifierProvider(
        create: (_) => AsignaturaProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => CompetenciaProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => RapProvider(),
      ),

      // ────────────────────────────────────────────────────────────────
      // PLANIFICACIÓN
      // ────────────────────────────────────────────────────────────────
      ChangeNotifierProvider(
        create: (_) => PlanificacionProvider(),
      ),

      // ────────────────────────────────────────────────────────────────
      // PROGRAMA
      // ────────────────────────────────────────────────────────────────
      ChangeNotifierProvider(
        create: (_) => ProgramaProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => ModuloProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => VersionProvider(),
      ),

      // ────────────────────────────────────────────────────────────────
      // REPORTES
      // ────────────────────────────────────────────────────────────────
      ChangeNotifierProvider(
        create: (_) => NovedadProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => ReporteProvider(),
      ),

      // ────────────────────────────────────────────────────────────────
      // EXPORTACIÓN
      // ────────────────────────────────────────────────────────────────
      ChangeNotifierProvider(
        create: (_) => ExportacionProvider(),
      ),

      // ────────────────────────────────────────────────────────────────
      // ANALÍTICA
      // ────────────────────────────────────────────────────────────────
      ChangeNotifierProvider(
        create: (_) => AnaliticaProvider(
          getDashboard: GetDashboardUseCase(analiticaRepo),
          getSnapshots: GetSnapshotsUseCase(analiticaRepo),
        ),
      ),

      // ────────────────────────────────────────────────────────────────
      // HORARIOS
      // ────────────────────────────────────────────────────────────────
      ChangeNotifierProvider(
        create: (_) => HorarioProvider(),
      ),

      // ────────────────────────────────────────────────────────────────
      // CHATBOT - Depende de AuthProvider para el token
      // ────────────────────────────────────────────────────────────────
      ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
        create: (_) => ChatProvider(
          sendMessage: SendMessageUsecase(chatbotRepo),
          clearConversation: const ClearConversationUsecase(),
        ),
        update: (_, auth, prev) {
          if (prev == null) {
            return ChatProvider(
              sendMessage: SendMessageUsecase(chatbotRepo),
              clearConversation: const ClearConversationUsecase(),
            )..updateToken(auth.accessToken);
          }
          prev.updateToken(auth.accessToken);
          return prev;
        },
      ),

      // ────────────────────────────────────────────────────────────────
      // NOTIFICACIONES - Depende de AuthProvider para el token y conexión WS
      // ────────────────────────────────────────────────────────────────
      ChangeNotifierProxyProvider<AuthProvider, NotificacionesProvider?>(
        create: (_) => null,
        update: (_, auth, prev) {
          if (!auth.isAuthenticated || auth.accessToken == null) {
            return null;
          }

          if (prev != null) {
            prev.reconnect(auth.accessToken!);
            return prev;
          }

          return NotificacionesProvider(
            repository: NotificacionesRepositoryImpl(
              token: auth.accessToken!,
              baseWsUrl: wsUrl.isNotEmpty ? wsUrl : 'ws://localhost:8000',
            ),
          );
        },
      ),
    ];
  }
}
