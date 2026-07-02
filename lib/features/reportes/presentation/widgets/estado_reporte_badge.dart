import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/reporte_generado_entity.dart';

class _EstadoVisual {
  const _EstadoVisual(this.color, this.icono, this.gira);
  final Color color;
  final IconData icono;
  final bool gira;
}

_EstadoVisual _visualPara(EstadoReporte estado) {
  switch (estado) {
    case EstadoReporte.pendiente:
      return const _EstadoVisual(
        AppTheme.textSecondary,
        Icons.schedule_rounded,
        false,
      );
    case EstadoReporte.procesando:
      return const _EstadoVisual(
        AppTheme.accent,
        Icons.autorenew_rounded,
        true,
      );
    case EstadoReporte.listo:
      return const _EstadoVisual(
        AppTheme.primary,
        Icons.check_circle_rounded,
        false,
      );
    case EstadoReporte.error:
      return const _EstadoVisual(Colors.redAccent, Icons.error_rounded, false);
  }
}

class EstadoReporteBadge extends StatefulWidget {
  const EstadoReporteBadge({
    super.key,
    required this.estado,
    required this.label,
  });

  final EstadoReporte estado;
  final String label;

  @override
  State<EstadoReporteBadge> createState() => _EstadoReporteBadgeState();
}

class _EstadoReporteBadgeState extends State<EstadoReporteBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1, milliseconds: 200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visual = _visualPara(widget.estado);

    final icono = visual.gira
        ? RotationTransition(
            turns: _controller,
            child: Icon(visual.icono, size: 16),
          )
        : Icon(visual.icono, size: 16);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: visual.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: visual.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTheme(
            data: IconThemeData(color: visual.color),
            child: icono,
          ),
          const SizedBox(width: 8),
          Text(
            widget.label,
            style: TextStyle(
              color: visual.color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
