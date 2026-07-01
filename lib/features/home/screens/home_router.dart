import 'package:flutter/material.dart';

import '../../alertas/presentation/screens/alertas_screen.dart';
import '../../analitica/presentation/screens/analitica_gestion_screen.dart';
import '../../aulas/presentation/screens/aula_gestion_screen.dart';
import '../../bhorario/presentation/screens/horario_screen.dart' as bhorario;
import '../../chatbot/presentation/screens/chat_screen.dart';
import '../../competencias/presentation/screens/competencias_gestion_screen.dart';
import '../../docentes/presentation/screens/docente_gestion_screen.dart';
import '../../exportacion/presentation/screens/exportacion_gestion_screen.dart';
import '../../ficha/presentation/screens/ficha_gestion_screen.dart';
import '../../notificaciones/presentation/screens/notificaciones_gestion_screen.dart';
import '../../planificacion/presentation/screens/planificacion_gestion_screen.dart';
import '../../programa/presentation/screens/programa_gestion_screen.dart';
import '../../reportes/presentation/screens/reportes_gestion_screen.dart';
import '../../users/screens/user_list_screen.dart';
import '../widgets/dashboard_view.dart';

/// Modelo de ítem del drawer.
class DrawerItem {
  final String   label;
  final IconData icon;
  const DrawerItem({required this.label, required this.icon});
}

/// Construye las listas de screens e ítems de drawer según el rol.
/// El índice de cada screen debe coincidir 1:1 con su DrawerItem.
abstract class HomeRouter {
  static List<Widget> buildScreens({
    required String role,
    required int    userId,
    required bool   isManager,
    required bool   isStaff,
  }) {
    return [
      // 0 — Dashboard (todos)
      const DashboardView(),

      // Manager
      if (isManager) const UserListScreen(),
      if (isManager) const AulasGestionScreen(),
      if (isManager) const DocenteGestionScreen(canManage: true),
      if (isManager) const FichaGestionScreen(),
      if (isManager) CompetenciasGestionScreen(userRole: role),
      if (isManager) const ProgramaGestionScreen(),
      if (isManager) const PlanificacionGestionScreen(),
      if (isManager) const AnaliticaGestionScreen(),
      if (isManager) ReportesGestionScreen(userRole: role),
      if (isManager) const ExportacionGestionScreen(),

      // Staff + Manager
      const bhorario.HorarioScreen(),
      if (isStaff) AlertasScreen(currentUserId: userId),
      if (isStaff) const NotificacionesGestionScreen(),

      // Todos
      const ChatScreen(),
    ];
  }

  static List<DrawerItem> buildDrawerItems({
    required bool isManager,
    required bool isStaff,
  }) {
    return [
      const DrawerItem(label: 'Inicio',         icon: Icons.home_rounded),

      if (isManager) ...const [
        DrawerItem(label: 'Usuarios',      icon: Icons.people_alt_rounded),
        DrawerItem(label: 'Gestión',       icon: Icons.business_center_rounded),
        DrawerItem(label: 'Docentes',      icon: Icons.school_rounded),
        DrawerItem(label: 'Fichas',        icon: Icons.folder_copy_rounded),
        DrawerItem(label: 'Competencias',  icon: Icons.menu_book_rounded),
        DrawerItem(label: 'Programas',     icon: Icons.library_books_rounded),
        DrawerItem(label: 'Planificación', icon: Icons.event_note_rounded),
        DrawerItem(label: 'Analítica',     icon: Icons.bar_chart_rounded),
        DrawerItem(label: 'Reportes',      icon: Icons.assessment_rounded),
        DrawerItem(label: 'Exportación',   icon: Icons.upload_file_rounded),
      ],

      const DrawerItem(label: 'Horarios',  icon: Icons.calendar_month_rounded),

      if (isStaff) ...const [
        DrawerItem(label: 'Alertas',          icon: Icons.warning_amber_rounded),
        DrawerItem(label: 'Notificaciones',   icon: Icons.notifications_active_rounded),
      ],

      const DrawerItem(label: 'Asistente', icon: Icons.smart_toy_outlined),
    ];
  }
}