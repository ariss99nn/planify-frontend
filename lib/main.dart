// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'config/app_providers_config.dart';
import 'config/app_routes_config.dart';
import 'config/features_exports.dart';
import 'core/api/api_service.dart';
import './core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ──────────────────────────────────────────────────────────────────────────
  // Cargar variables de entorno
  // ──────────────────────────────────────────────────────────────────────────
  await dotenv.load(fileName: 'assets/config/.env');

  // ──────────────────────────────────────────────────────────────────────────
  // Configurar URLs (desde environment variables o .env)
  // ──────────────────────────────────────────────────────────────────────────
  const _dartApi = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  const _dartWs = String.fromEnvironment('WS_BASE_URL', defaultValue: '');

  final apiUrl = _dartApi.isNotEmpty
      ? _dartApi
      : (dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000');

  final wsUrl = _dartWs.isNotEmpty
      ? _dartWs
      : (dotenv.env['WS_BASE_URL'] ?? 'ws://localhost:8000');

  // Configurar servicio de API
  ApiService.configure(baseUrl: apiUrl);

  runApp(PlanifyApp(apiUrl: apiUrl, wsUrl: wsUrl));
}

// ──────────────────────────────────────────────────────────────────────────────
// Widget principal de la aplicación
// ──────────────────────────────────────────────────────────────────────────────
class PlanifyApp extends StatelessWidget {
  final String apiUrl;
  final String wsUrl;

  const PlanifyApp({
    super.key,
    required this.apiUrl,
    required this.wsUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Configurar providers mediante la clase centralizada
    final providersConfig = AppProvidersConfig(
      apiUrl: apiUrl,
      wsUrl: wsUrl,
    );

    return MultiProvider(
      providers: providersConfig.build().cast(),
      child: MaterialApp(
        title: 'PLANIFY',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,

        // ────────────────────────────────────────────────────────────────
        // Pantalla inicial protegida con AuthGuard
        // ────────────────────────────────────────────────────────────────
        home: AuthGuard(child: const HomeScreen()),

        // ────────────────────────────────────────────────────────────────
        // Rutas estáticas (sin parámetros dinámicos)
        // ────────────────────────────────────────────────────────────────
        routes: AppRoutesConfig.staticRoutes,

        // ────────────────────────────────────────────────────────────────
        // Rutas dinámicas (con parámetros numéricos)
        // ────────────────────────────────────────────────────────────────
        onGenerateRoute: AppRoutesConfig.onGenerateRoute,
      ),
    );
  }
}