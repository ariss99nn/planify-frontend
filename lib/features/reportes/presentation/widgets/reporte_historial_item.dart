import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/reporte_generado_entity.dart';
import 'estado_reporte_badge.dart';

class ReporteHistorialItem extends StatelessWidget {
  const ReporteHistorialItem({
    super.key,
    required this.reporte,
    required this.onTap,
  });

  final ReporteGeneradoEntity reporte;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formato = DateFormat('d MMM, HH:mm', 'es');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reporte.tipoDisplay,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formato.format(reporte.createdAt),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                EstadoReporteBadge(
                  estado: reporte.estado,
                  label: reporte.estadoDisplay,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
