import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../../../core/api/api_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _rolLabel(UserModel user) {
    if (user.esAdministrativo) return 'Administrativo';
    if (user.esCoordinador)    return 'Coordinador';
    if (user.esDocente)        return 'Docente';
    return 'Estudiante';
  }

  IconData _rolIcon(UserModel user) {
    if (user.puedeGestionarUsuarios) return Icons.admin_panel_settings;
    if (user.esDocente)              return Icons.school_outlined;
    return Icons.person_outline;
  }

  @override
  Widget build(BuildContext context) {
    final auth       = context.watch<AuthProvider>();
    final UserModel? user = auth.user;

    // ── Estado vacío ──────────────────────────────────────────────────────
    if (user == null) {
      return CyberScaffold(
        child: Center(
          child: CyberCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 56, color: AppTheme.primary),
                const SizedBox(height: 16),
                Text(
                  'No hay usuario autenticado',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                CyberButton(
                  label: 'Ir al login',
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final String? imageUrl = ApiService.buildMediaUrl(user.imagenUrl);

    // 🔍 DEBUG — eliminar una vez que la imagen cargue
    debugPrint('🖼️ imagenUrl raw:  ${user.imagenUrl}');
    debugPrint('🖼️ imageUrl full:  $imageUrl');
    debugPrint('🌐 hostUrl:        ${ApiService.hostUrl}');

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: CyberCard(
              child: Column(
                children: [

                  // Avatar
                  CyberProfileAvatar(imageUrl: imageUrl),
                  const SizedBox(height: 24),

                  // Nombre
                  Text(
                    user.nombreCompleto,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Rol
                  CyberRoleBadge(
                    label: _rolLabel(user),
                    icon: _rolIcon(user),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  CyberInfoRow(
                    icon: Icons.email_outlined,
                    text: user.email,
                  ),

                  // Badge correo no verificado
                  if (!user.emailVerificado) ...[
                    const SizedBox(height: 8),
                    const CyberWarningBadge(label: 'Correo no verificado'),
                  ],

                  const SizedBox(height: 8),

                  // Miembro desde
                  CyberInfoRow(
                    icon: Icons.calendar_today,
                    text: 'Miembro desde ${user.fechaCreacion.year}',
                    iconSize: 15,
                    fontSize: 12,
                  ),

                  const SizedBox(height: 32),

                  // Editar perfil
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/edit-profile'),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar perfil'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cerrar sesión
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await CyberDialog.confirm(
                          context: context,
                          icon: Icons.logout,
                          title: 'Cerrar sesión',
                          message: '¿Estás seguro de que quieres cerrar sesión?',
                          confirmLabel: 'Cerrar sesión',
                          destructive: true,
                        );
                        if (confirm == true && context.mounted) {
                          auth.logout();
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}