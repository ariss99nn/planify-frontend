import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/notificacion_entity.dart';
import '../providers/notificaciones_provider.dart';

mixin AlertaToastMixin<T extends StatefulWidget> on State<T> {
  NotificacionEntity? _lastShown;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = context.read<NotificacionesProvider?>();
    notifier?.removeListener(_onNotif);
    notifier?.addListener(_onNotif);
  }

  @override
  void dispose() {
    context.read<NotificacionesProvider?>()?.removeListener(_onNotif);
    super.dispose();
  }

  void _onNotif() {
    if (!mounted) return;
    final msg = context.read<NotificacionesProvider?>()?.ultimoMensaje;
    if (msg == null || identical(msg, _lastShown)) return;
    _lastShown = msg;
    AlertaToast.show(context, msg);
  }
}

class AlertaToast {
  AlertaToast._();

  static void show(BuildContext context, NotificacionEntity msg) {
    final key = msg.tipoAlerta ?? msg.tipo.name;

    final (icon, color, label) = switch (key) {
      'CONFLICTO' || 'conflicto_horario' => (
        Icons.warning_amber_rounded,
        const Color(0xFFA32D2D),
        'Conflicto de horario',
      ),
      'DISPONIBILIDAD' => (
        Icons.calendar_today_outlined,
        const Color(0xFF185FA5),
        'Disponibilidad',
      ),
      'SISTEMA' => (
        Icons.settings_outlined,
        const Color(0xFF854F0B),
        'Sistema',
      ),
      _ => (Icons.notifications_outlined, AppTheme.primary, 'Notificación'),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 6,
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    if (msg.descripcion != null)
                      Text(
                        msg.descripcion!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.3,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
}
