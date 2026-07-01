import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/reporte_generado_entity.dart';

class ReporteTipoTile extends StatelessWidget {
  const ReporteTipoTile({
    super.key,
    required this.tipo,
    required this.onTap,
  });

  final ReporteTipo tipo;
  final VoidCallback? onTap;

  bool get _habilitado => onTap != null && tipo.implementadoEnBackend;

  IconData get _icono {
    switch (tipo) {
      case ReporteTipo.fichas:
        return Icons.badge_outlined;
      case ReporteTipo.docentes:
        return Icons.school_outlined;
      case ReporteTipo.horarios:
        return Icons.calendar_month_outlined;
      case ReporteTipo.competencias:
        return Icons.workspace_premium_outlined;
      case ReporteTipo.aulas:
        return Icons.meeting_room_outlined;
      case ReporteTipo.analitica:
        return Icons.insights_outlined;
      case ReporteTipo.novedades:
        return Icons.notifications_active_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final habilitado = _habilitado;

    return Opacity(
      opacity: habilitado ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: habilitado ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_icono, color: AppTheme.primary, size: 28),
                const SizedBox(height: 10),
                Text(
                  tipo.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (!tipo.implementadoEnBackend) ...[
                  const SizedBox(height: 6),
                  const Text(
                    'Próximamente',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
