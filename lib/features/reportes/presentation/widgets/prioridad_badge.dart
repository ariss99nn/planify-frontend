import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/novedad_entity.dart';

Color colorPrioridad(NovedadPrioridad prioridad) {
  switch (prioridad) {
    case NovedadPrioridad.alta:
      return Colors.redAccent;
    case NovedadPrioridad.media:
      return AppTheme.accent;
    case NovedadPrioridad.baja:
      return AppTheme.textSecondary;
  }
}

class PrioridadBadge extends StatelessWidget {
  const PrioridadBadge({super.key, required this.prioridad});

  final NovedadPrioridad prioridad;

  @override
  Widget build(BuildContext context) {
    final color = colorPrioridad(prioridad);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            prioridad.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
