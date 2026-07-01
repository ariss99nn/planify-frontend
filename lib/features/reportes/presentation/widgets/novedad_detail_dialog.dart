import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/novedad_entity.dart';
import 'prioridad_badge.dart';

class NovedadDetailDialog extends StatelessWidget {
  const NovedadDetailDialog({super.key, required this.novedad});

  final NovedadEntity novedad;

  static Future<void> mostrar(BuildContext context, NovedadEntity novedad) {
    return showDialog<void>(
      context: context,
      builder: (_) => NovedadDetailDialog(novedad: novedad),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('d MMM yyyy, HH:mm', 'es');

    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Expanded(
            child: Text(
              novedad.titulo,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const Icon(Icons.task_alt_rounded, color: AppTheme.primary, size: 20),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                PrioridadBadge(prioridad: novedad.prioridad),
                const SizedBox(width: 8),
                Text(
                  novedad.tipoDisplay,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Descripción',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(novedad.descripcion,
                style: const TextStyle(color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            const Text(
              'Resolución',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              novedad.notaAtencion.isEmpty
                  ? 'Sin nota registrada.'
                  : novedad.notaAtencion,
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              [
                if (novedad.atendidaPorNombre != null)
                  'Atendida por ${novedad.atendidaPorNombre}',
                if (novedad.fechaAtencion != null)
                  'el ${formatoFecha.format(novedad.fechaAtencion!)}',
              ].join(' '),
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
