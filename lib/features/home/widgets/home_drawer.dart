import 'package:flutter/material.dart';

import '../../../core/api/api_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../screens/home_router.dart';

class HomeDrawer extends StatelessWidget {
  final AuthProvider     auth;
  final List<DrawerItem> items;
  final int              currentIndex;
  final ValueChanged<int> onTap;
  final bool             permanent;

  const HomeDrawer({
    super.key,
    required this.auth,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.permanent,
  });

  @override
  Widget build(BuildContext context) {
    final user      = auth.user!;
    final avatarUrl = ApiService.buildMediaUrl(user.imagenUrl);

    return Drawer(
      elevation:       permanent ? 0 : 4,
      backgroundColor: AppTheme.surface.withOpacity(0.92),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _Logo(context),
            const SizedBox(height: 28),
            _Avatar(avatarUrl: avatarUrl),
            const SizedBox(height: 12),
            Text(
              user.nombreCompleto,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(user.email,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/edit-profile'),
              icon: const Icon(Icons.edit_outlined,
                  size: 16, color: AppTheme.primary),
              label: const Text('Editar perfil'),
            ),
            Divider(color: AppTheme.border, height: 28),
            Expanded(
              child: _NavList(
                items:        items,
                currentIndex: currentIndex,
                permanent:    permanent,
                onTap:        onTap,
              ),
            ),
            Divider(color: AppTheme.border, height: 1),
            _LogoutTile(auth: auth, permanent: permanent),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _Logo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bolt_rounded, color: AppTheme.primary, size: 22),
          const SizedBox(width: 6),
          Text(
            'PLANIFY',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontSize: 20, letterSpacing: 1.4),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? avatarUrl;
  const _Avatar({required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/profile'),
      child: CyberProfileAvatar(imageUrl: avatarUrl, radius: 42),
    );
  }
}

class _NavList extends StatelessWidget {
  final List<DrawerItem> items;
  final int              currentIndex;
  final bool             permanent;
  final ValueChanged<int> onTap;

  const _NavList({
    required this.items,
    required this.currentIndex,
    required this.permanent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding:   EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item     = items[index];
        final selected = currentIndex == index;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            leading: Icon(
              item.icon,
              color: selected ? AppTheme.primary : AppTheme.textSecondary,
              size: 20,
            ),
            title: Text(
              item.label,
              style: TextStyle(
                fontSize:   14,
                color:      selected ? AppTheme.primary : AppTheme.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            selected:          selected,
            selectedTileColor: AppTheme.primary.withOpacity(0.1),
            onTap: () {
              onTap(index);
              if (!permanent) Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}

class _LogoutTile extends StatelessWidget {
  final AuthProvider auth;
  final bool         permanent;
  const _LogoutTile({required this.auth, required this.permanent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        leading: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
        title: const Text('Cerrar sesión',
            style: TextStyle(color: Colors.redAccent, fontSize: 14)),
        onTap: () async {
          if (!permanent) Navigator.pop(context);
          final confirm = await CyberDialog.confirm(
            context: context,
            icon:         Icons.logout,
            title:        'Cerrar sesión',
            message:      '¿Estás seguro de que quieres cerrar sesión?',
            confirmLabel: 'Cerrar sesión',
            destructive:  true,
          );
          if (confirm == true && context.mounted) {
            await auth.logout();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (_) => false);
          }
        },
      ),
    );
  }
}