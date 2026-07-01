import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notificaciones_provider.dart';
import '../screens/notificaciones_gestion_screen.dart';

class NotificacionBadge extends StatelessWidget {
  const NotificacionBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final noLeidas = context.select<NotificacionesProvider, int>(
      (n) => n.noLeidas,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: Theme.of(context).iconTheme.color,
          ),
          tooltip: 'Notificaciones',
          onPressed: () {
            context.read<NotificacionesProvider>().marcarTodasLeidas();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: context.read<NotificacionesProvider>(),
                  child: const NotificacionesGestionScreen(),
                ),
              ),
            );
          },
        ),
        if (noLeidas > 0)
          Positioned(
            top: 6,
            right: 6,
            child: IgnorePointer(
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  noLeidas > 9 ? '9+' : '$noLeidas',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
