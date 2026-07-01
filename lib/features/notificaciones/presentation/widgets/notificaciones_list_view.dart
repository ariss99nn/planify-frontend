import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/notificacion_entity.dart';
import '../providers/notificaciones_provider.dart';

class NotificacionesListView extends StatelessWidget {
  const NotificacionesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificacionesProvider>();

    final mensajes = provider.mensajes
        .where((m) =>
            m.tipo == TipoNotificacion.alerta_nueva ||
            m.tipo == TipoNotificacion.conflicto_horario)
        .toList();

    if (mensajes.isEmpty) {
      return const CyberEmptyView(
        icon: Icons.notifications_none_rounded,
        title: 'Sin notificaciones',
        message: 'Aquí aparecerán tus alertas en tiempo real.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: mensajes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _NotifTile(msg: mensajes[i]),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificacionEntity msg;
  const _NotifTile({required this.msg});

  @override
  Widget build(BuildContext context) {
    final key = msg.tipoAlerta ?? msg.tipo.name;

    final (icon, color, bgColor, label) = switch (key) {
      'CONFLICTO' || 'conflicto_horario' => (
          Icons.warning_amber_rounded,
          const Color(0xFFA32D2D),
          const Color(0xFFFCEBEB),
          'Conflicto de horario',
        ),
      'SISTEMA' => (
          Icons.settings_outlined,
          const Color(0xFF854F0B),
          const Color(0xFFFAEEDA),
          'Sistema',
        ),
      _ => (
          Icons.notifications_outlined,
          const Color(0xFF185FA5),
          const Color(0xFFE6F1FB),
          'Alerta nueva',
        ),
    };

    final fecha = msg.fecha != null ? DateTime.tryParse(msg.fecha!) : null;
    final fechaStr = fecha != null
        ? '${fecha.day}/${fecha.month} '
          '${fecha.hour.toString().padLeft(2, '0')}:'
          '${fecha.minute.toString().padLeft(2, '0')}'
        : '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      fechaStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  msg.descripcion ?? '',
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
