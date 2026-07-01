import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/api/api_service.dart';
import '../../../../../core/theme/theme.dart';
import '../../../domain/entities/reporte_generado_entity.dart';
import '../../providers/reporte_provider.dart';
import '../estado_reporte_badge.dart';

class ReporteEstadoView extends StatefulWidget {
  const ReporteEstadoView({
    super.key,
    required this.reporteId,
  });

  final int reporteId;

  @override
  State<ReporteEstadoView> createState() => _ReporteEstadoViewState();
}

class _ReporteEstadoViewState extends State<ReporteEstadoView> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<ReporteProvider>();
    final activo = provider.reporteActivo;
    if (activo == null || activo.id != widget.reporteId) {
      provider.consultarReporte(widget.reporteId);
    }
  }

  @override
  void dispose() {
    context.read<ReporteProvider>().detenerSeguimiento();
    super.dispose();
  }

  Future<void> _abrirArchivo(String? rutaArchivo) async {
    final url = ApiService.buildMediaUrl(rutaArchivo);
    if (url == null) return;

    final uri = Uri.parse(url);
    final exito = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!exito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el archivo.')),
      );
    }
  }

  void _reintentar(ReporteGeneradoEntity reporte) {
    context
        .read<ReporteProvider>()
        .solicitar(tipo: reporte.tipo, filtros: reporte.filtros);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReporteProvider>();
    final reporte = provider.reporteActivo;

    if (provider.consultandoEstado && reporte == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (reporte == null) {
      return Center(
        child: Text(
          provider.errorEstado ?? 'No se encontró el reporte.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return _Contenido(
      reporte: reporte,
      seguimientoAgotado: provider.seguimientoAgotado,
      onAbrirPdf: () => _abrirArchivo(reporte.archivoPdfUrl),
      onAbrirExcel: () => _abrirArchivo(reporte.archivoExcelUrl),
      onReintentar: () => _reintentar(reporte),
      onVerificarAhora: () =>
          context.read<ReporteProvider>().consultarReporte(reporte.id),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({
    required this.reporte,
    required this.seguimientoAgotado,
    required this.onAbrirPdf,
    required this.onAbrirExcel,
    required this.onReintentar,
    required this.onVerificarAhora,
  });

  final ReporteGeneradoEntity reporte;
  final bool seguimientoAgotado;
  final VoidCallback onAbrirPdf;
  final VoidCallback onAbrirExcel;
  final VoidCallback onReintentar;
  final VoidCallback onVerificarAhora;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reporte.tipoDisplay,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          EstadoReporteBadge(
              estado: reporte.estado, label: reporte.estadoDisplay),
          const SizedBox(height: 28),
          Expanded(child: _cuerpoSegunEstado(context)),
        ],
      ),
    );
  }

  Widget _cuerpoSegunEstado(BuildContext context) {
    switch (reporte.estado) {
      case EstadoReporte.pendiente:
      case EstadoReporte.procesando:
        return seguimientoAgotado
            ? _SeguimientoAgotadoView(onVerificarAhora: onVerificarAhora)
            : const _EnProcesoView();
      case EstadoReporte.listo:
        return _ListoView(onAbrirPdf: onAbrirPdf, onAbrirExcel: onAbrirExcel);
      case EstadoReporte.error:
        return _ErrorReporteView(
          mensaje: reporte.errorMensaje,
          onReintentar: onReintentar,
        );
    }
  }
}

class _SeguimientoAgotadoView extends StatelessWidget {
  const _SeguimientoAgotadoView({required this.onVerificarAhora});

  final VoidCallback onVerificarAhora;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hourglass_bottom_rounded,
              color: AppTheme.accent, size: 40),
          const SizedBox(height: 16),
          const Text(
            'Está tardando más de lo esperado',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'El reporte sigue generándose en el servidor. Puedes verificar el estado cuando quieras.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: onVerificarAhora,
              child: const Text('Verificar ahora')),
        ],
      ),
    );
  }
}

class _EnProcesoView extends StatelessWidget {
  const _EnProcesoView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
                strokeWidth: 3, color: AppTheme.accent),
          ),
          SizedBox(height: 20),
          Text(
            'Generando el reporte…',
            style: TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            'Esto puede tardar unos segundos. No es necesario que esperes en esta pantalla.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ListoView extends StatelessWidget {
  const _ListoView({required this.onAbrirPdf, required this.onAbrirExcel});

  final VoidCallback onAbrirPdf;
  final VoidCallback onAbrirExcel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppTheme.primary, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Reporte listo',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAbrirPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Abrir PDF'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onAbrirExcel,
            icon: const Icon(Icons.table_chart_outlined),
            label: const Text('Abrir Excel'),
          ),
        ],
      ),
    );
  }
}

class _ErrorReporteView extends StatelessWidget {
  const _ErrorReporteView(
      {required this.mensaje, required this.onReintentar});

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_rounded, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          const Text(
            'No se pudo generar el reporte',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          if (mensaje.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton(
              onPressed: onReintentar, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
