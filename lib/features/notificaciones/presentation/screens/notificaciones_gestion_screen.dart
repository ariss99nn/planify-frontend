import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notificaciones_provider.dart';
import '../widgets/notificaciones_list_view.dart';

class NotificacionesGestionScreen extends StatelessWidget {
  const NotificacionesGestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificacionesProvider?>();

    if (provider == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: provider.conectado
                        ? const Color(0xFF69F0AE)
                        : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  provider.conectado ? 'En vivo' : 'Desconectado',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: const NotificacionesListView(),
    );
  }
}
