import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../providers/user_provider.dart';
import '../../../core/api/api_service.dart';
import '../../../core/theme/theme.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserProvider>().fetchUsers());
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  String _rolLabel(String rol) {
    switch (rol) {
      case 'ADMINISTRATIVO':
        return 'Administrativo';
      case 'COORDINADOR':
        return 'Coordinador';
      case 'DOCENTE':
        return 'Docente';
      case 'ESTUDIANTE':
        return 'Estudiante';
      default:
        return rol;
    }
  }

  // 👇 Gama de verdes acorde al tema cyber
  Color _rolColor(String rol) {
    switch (rol) {
      case 'ADMINISTRATIVO':
        return const Color(0xFF35F58A); // verde neón principal
      case 'COORDINADOR':
        return const Color(0xFF14C768); // verde medio
      case 'DOCENTE':
        return const Color(0xFF0E9E52); // verde oscuro
      case 'ESTUDIANTE':
        return const Color(0xFF1D7A45); // verde bosque
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _rolIcon(String rol) {
    switch (rol) {
      case 'ADMINISTRATIVO':
        return Icons.admin_panel_settings;
      case 'COORDINADOR':
        return Icons.manage_accounts;
      case 'DOCENTE':
        return Icons.school;
      case 'ESTUDIANTE':
        return Icons.person;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildAvatar(UserModel u) {
    final imagenFullUrl = ApiService.buildMediaUrl(u.imagenUrl);
    final rolColor = _rolColor(u.rol);
    final iniciales = [
      if (u.nombre.isNotEmpty) u.nombre[0],
      if (u.apellido.isNotEmpty) u.apellido[0],
    ].join().toUpperCase();

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: rolColor, width: 2),
      ),
      child: ClipOval(
        child: SizedBox(
          width: 52,
          height: 52,
          child: imagenFullUrl != null && imagenFullUrl.isNotEmpty
              ? Image.network(
                  imagenFullUrl,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _inicialAvatar(iniciales, rolColor),
                )
              : _inicialAvatar(iniciales, rolColor),
        ),
      ),
    );
  }

  Widget _inicialAvatar(String iniciales, Color rolColor) {
    return Container(
      color: rolColor.withValues(alpha: 0.12),
      child: Center(
        child: Text(
          iniciales.isNotEmpty ? iniciales : '?',
          style: TextStyle(
            color: rolColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  void _showDeactivateConfirmDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.person_off_outlined,
          color: Colors.red,
          size: 40,
        ),
        title: const Text('Desactivar usuario'),
        content: Text(
          '¿Estás seguro de desactivar a ${user.nombre} ${user.apellido}?\n\nEl usuario no podrá iniciar sesión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deactivateUser(user.id);
            },
            child: const Text(
              'Desactivar',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showActivateConfirmDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.person_add_outlined,
          color: Colors.green,
          size: 40,
        ),
        title: const Text('Activar usuario'),
        content: Text(
          '¿Estás seguro de activar a ${user.nombre} ${user.apellido}?\n\nEl usuario podrá iniciar sesión nuevamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _activateUser(user.id);
            },
            child: const Text(
              'Activar',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deactivateUser(int userId) async {
    try {
      await UserService.deactivateUser(userId);
      if (!mounted) return;
      await context.read<UserProvider>().fetchUsers(search: searchCtrl.text);
      if (!mounted) return;

      final users = context.read<UserProvider>().users;
      final u = users.where((u) => u.id == userId).firstOrNull;
      debugPrint('📦 isActive después de deactivate: ${u?.isActive}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario desactivado exitosamente'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _activateUser(int userId) async {
    try {
      await UserService.activateUser(userId);
      if (!mounted) return;
      await context.read<UserProvider>().fetchUsers(search: searchCtrl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario activado exitosamente'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _goToEdit(int userId) async {
    await Navigator.pushNamed(context, '/users/edit/$userId');
    if (!mounted) return;
    context.read<UserProvider>().fetchUsers(search: searchCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final currentUserId = context.watch<AuthProvider>().user?.id;

    return Scaffold(
      // 👇 AppBar con color oscuro del tema y tipografía seria
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        title: const Text(
          'USUARIOS',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.0,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primary),
            onPressed: () => context.read<UserProvider>().fetchUsers(
              search: searchCtrl.text,
            ),
            tooltip: 'Recargar',
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Buscador ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border.withOpacity(0.5)),
              ),
              child: TextField(
                controller: searchCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Buscar usuarios...',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.5),
                  ),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: searchCtrl.text.isEmpty
                          ? AppTheme.textSecondary.withOpacity(0.3)
                          : AppTheme.primary,
                    ),
                    onPressed: () {
                      if (searchCtrl.text.isNotEmpty) {
                        searchCtrl.clear();
                        context.read<UserProvider>().fetchUsers(search: '');
                      }
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (value) =>
                    context.read<UserProvider>().fetchUsers(search: value),
              ),
            ),
          ),

          // ── Contador ─────────────────────────────────────────────
          if (!provider.loading && provider.users.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${provider.users.length} usuarios encontrados',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withOpacity(0.6),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

          // ── Contenido ────────────────────────────────────────────
          if (provider.loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (provider.users.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: AppTheme.primary.withOpacity(0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay usuarios',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.textSecondary.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Prueba con otra búsqueda',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: provider.users.length,
                itemBuilder: (_, i) {
                  final u = provider.users[i];
                  final rolColor = _rolColor(u.rol);

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      // 👇 muy transparente
                      color: AppTheme.surface.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.border.withOpacity(0.3),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          _buildAvatar(u),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${u.nombre} ${u.apellido}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  u.email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    // Badge rol
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: rolColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: rolColor.withValues(
                                            alpha: 0.4,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _rolIcon(u.rol),
                                            size: 12,
                                            color: rolColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _rolLabel(u.rol),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: rolColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),

                                    // Badge activo/inactivo
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: u.isActive
                                            ? AppTheme.primary.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: u.isActive
                                              ? AppTheme.primary.withOpacity(
                                                  0.4,
                                                )
                                              : Colors.red.withOpacity(0.4),
                                        ),
                                      ),
                                      child: Text(
                                        u.isActive ? 'Activo' : 'Inactivo',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: u.isActive
                                              ? AppTheme.primary
                                              : Colors.red.shade400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // ── Botones de acción ──────────────────
                          // El usuario en sesión no se edita ni se
                          // desactiva a sí mismo desde este panel: eso se
                          // hace desde "Editar perfil".
                          if (u.id == currentUserId)
                            Tooltip(
                              message: 'Edita tu cuenta desde tu perfil',
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.primary.withOpacity(0.4),
                                  ),
                                ),
                                child: const Text(
                                  'Tú',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            )
                          else
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ActionButton(
                                  icon: Icons.edit_outlined,
                                  color: AppTheme.primary,
                                  tooltip: 'Editar',
                                  onTap: () => _goToEdit(u.id),
                                ),
                                const SizedBox(height: 6),
                                if (u.isActive)
                                  _ActionButton(
                                    icon: Icons.person_off_outlined,
                                    color: Colors.red.shade400,
                                    tooltip: 'Desactivar',
                                    onTap: () => _showDeactivateConfirmDialog(
                                        context, u),
                                  )
                                else
                                  _ActionButton(
                                    icon: Icons.person_add_outlined,
                                    color: AppTheme.primary,
                                    tooltip: 'Activar',
                                    onTap: () => _showActivateConfirmDialog(
                                        context, u),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_users',
        onPressed: () async {
          await Navigator.pushNamed(context, '/users/create');
          if (!mounted) return;
          context.read<UserProvider>().fetchUsers(search: searchCtrl.text);
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.background,
        tooltip: 'Crear usuario',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
