import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/theme.dart';
import '../../../domain/entities/reporte_generado_entity.dart';
import '../../providers/reporte_provider.dart';
import '../reporte_historial_item.dart';
import '../reporte_tipo_tile.dart';

class ReportesView extends StatelessWidget {
  const ReportesView({
    super.key,
    required this.userRole,
    required this.onVerEstado,
  });

  final String userRole;
  final void Function(int reporteId) onVerEstado;

  Future<void> _solicitar(BuildContext context, ReporteTipo tipo) async {
    final provider = context.read<ReporteProvider>();
    final reporte = await provider.solicitar(tipo: tipo);

    if (!context.mounted) return;

    if (reporte == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(provider.errorSolicitud ?? 'No se pudo solicitar el reporte.'),
          backgroundColor: Colors.redAccent.shade700,
        ),
      );
      return;
    }

    onVerEstado(reporte.id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReporteProvider>();
    final tipos = ReporteTipoX.permitidosParaRol(userRole);

    if (provider.solicitando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                  strokeWidth: 3, color: AppTheme.primary),
            ),
            SizedBox(height: 16),
            Text('Solicitando reporte…',
                style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        const Text(
          'Generar nuevo reporte',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Se genera en segundo plano. Te avisamos cuando esté listo.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: tipos
              .map((t) => ReporteTipoTile(
                    tipo: t,
                    onTap: () => _solicitar(context, t),
                  ))
              .toList(),
        ),
        if (provider.historial.isNotEmpty) ...[
          const SizedBox(height: 28),
          const Text(
            'Historial de esta sesión',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ...provider.historial.map(
            (r) => ReporteHistorialItem(
              reporte: r,
              onTap: () => onVerEstado(r.id),
            ),
          ),
        ],
      ],
    );
  }
}
