import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_roles.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/home_navigation_provider.dart';
import '../widgets/dashboard_view.dart';
import '../widgets/home_background.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_drawer.dart';
import 'home_router.dart';

/// Pantalla principal de la aplicación - Shell navegación
/// Maneja la navegación entre diferentes módulos según el rol del usuario
/// Utiliza HomeNavigationProvider para el estado de navegación
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1000;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final navProvider = context.watch<HomeNavigationProvider>();
    final user = auth.user;

    if (user == null) return _NoSessionView();

    final role = user.rol;
    final bool isManager = AppRoles.managers.contains(role);
    final bool isStaff = AppRoles.staff.contains(role);
    final bool isEstudiante = role == AppRoles.estudiante;

    final screens = HomeRouter.buildScreens(
      role: role,
      userId: user.id,
      isManager: isManager,
      isStaff: isStaff,
    );
    final drawerItems = HomeRouter.buildDrawerItems(
      isManager: isManager,
      isStaff: isStaff,
    );

    final safeIndex = navProvider.currentIndex.clamp(0, screens.length - 1);
    final isDesktop = _isDesktop(context);

    return Scaffold(
      drawer: (!isEstudiante && !isDesktop)
          ? _buildHomeDrawer(
              context: context,
              auth: auth,
              drawerItems: drawerItems,
              safeIndex: safeIndex,
              permanent: false,
            )
          : null,
      body: Stack(
        children: [
          const HomeBackground(),
          Row(
            children: [
              if (isDesktop && !isEstudiante)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: navProvider.drawerVisible ? 280 : 0,
                  child: navProvider.drawerVisible
                      ? _buildHomeDrawer(
                          context: context,
                          auth: auth,
                          drawerItems: drawerItems,
                          safeIndex: safeIndex,
                          permanent: true,
                        )
                      : const SizedBox.shrink(),
                ),
              Expanded(
                child:
                    IndexedStack(index: safeIndex, children: screens),
              ),
            ],
          ),
          if (isDesktop && !isEstudiante)
            _DrawerToggleButton(
              visible: navProvider.drawerVisible,
              onToggle: () =>
                  context.read<HomeNavigationProvider>().toggleDrawer(),
            ),
        ],
      ),
      bottomNavigationBar: isEstudiante
          ? HomeBottomNav(
              currentIndex: safeIndex,
              onTap: (index) =>
                  context.read<HomeNavigationProvider>().setCurrentIndex(index),
            )
          : null,
    );
  }

  /// Construye el drawer con los items basados en el rol
  HomeDrawer _buildHomeDrawer({
    required BuildContext context,
    required AuthProvider auth,
    required List<DrawerItem> drawerItems,
    required int safeIndex,
    required bool permanent,
  }) =>
      HomeDrawer(
        auth: auth,
        items: drawerItems,
        currentIndex: safeIndex,
        onTap: (index) =>
            context.read<HomeNavigationProvider>().setCurrentIndex(index),
        permanent: permanent,
      );
}

// ── Sin sesión ────────────────────────────────────────────────────────────────
class _NoSessionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CyberScaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off, size: 56, color: AppTheme.primary),
              const SizedBox(height: 16),
              Text('No hay sesión activa',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              CyberButton(
                label: 'Iniciar sesión',
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Botón toggle drawer desktop ───────────────────────────────────────────────
class _DrawerToggleButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onToggle;
  const _DrawerToggleButton({required this.visible, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: visible ? 288 : 8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppTheme.border.withOpacity(0.5)),
              ),
              child: Icon(
                visible
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: AppTheme.primary,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}