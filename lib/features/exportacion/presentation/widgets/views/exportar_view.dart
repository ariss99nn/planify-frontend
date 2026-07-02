import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/cyber_button.dart';
import '../../../../../core/widgets/cyber_card.dart';
import '../../../../../core/widgets/cyber_error_banner.dart';
import '../../../../../core/widgets/cyber_section_label.dart';
import '../../../../../core/widgets/cyber_snackbar.dart';
import '../../config/filtros_modulo.dart';
import '../../../domain/entities/export_result.dart';
import '../../../domain/entities/exportacion_enums.dart';
import '../../providers/exportacion_provider.dart';

class ExportarView extends StatefulWidget {
  const ExportarView({super.key});

  @override
  State<ExportarView> createState() => _ExportarViewState();
}

class _ExportarViewState extends State<ExportarView> {
  TipoExportacion    _modulo  = TipoExportacion.fichas;
  FormatoExportacion _formato = FormatoExportacion.excel;

  final Map<String, TextEditingController> _controllers   = {};
  final Map<String, String>                _seleccionados = {};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, String> get _filtrosActuales {
    final filtros = <String, String>{};
    for (final campo in kFiltrosPorModulo[_modulo] ?? const []) {
      if (campo.esSelect) {
        final v = _seleccionados[campo.key];
        if (v != null && v.isNotEmpty) filtros[campo.key] = v;
      } else {
        final v = _controllers[campo.key]?.text.trim();
        if (v != null && v.isNotEmpty) filtros[campo.key] = v;
      }
    }
    return filtros;
  }

  int get _filtrosActivos => _filtrosActuales.length;

  void _onModuloChanged(TipoExportacion? nuevo) {
    if (nuevo == null || nuevo == _modulo) return;
    setState(() {
      _modulo = nuevo;
      _seleccionados.clear();
      for (final c in _controllers.values) {
        c.clear();
      }
      if (nuevo.soloExcel) {
        _formato = FormatoExportacion.excel;
      }
    });
    context.read<ExportacionProvider>().resetExport();
  }

  Future<void> _exportar() async {
    final provider = context.read<ExportacionProvider>();
    await provider.exportar(
      modulo:  _modulo,
      formato: _formato,
      filtros: _filtrosActuales,
    );

    if (!mounted) return;

    final result = provider.lastResult;
    if (provider.exportSuccess && result != null) {
      if (result.isWeb) {
        // En Web la descarga ya la disparó el navegador (Blob + <a download>).
        CyberSnackbar.success(context, 'Descarga iniciada: ${result.fileName}');
      } else {
        CyberSnackbar.success(context, 'Archivo descargado correctamente');
        await OpenFilex.open(result.filePath!);
      }
    } else if (provider.hasExportError) {
      CyberSnackbar.error(
        context,
        provider.exportError ?? 'Error al exportar',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider    = context.watch<ExportacionProvider>();
    final isExporting = provider.isExporting;
    final campos      = kFiltrosPorModulo[_modulo] ?? const [];
    final formatos    = _modulo.soloExcel
        ? [FormatoExportacion.excel]
        : FormatoExportacion.values;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(modulo: _modulo),
          const SizedBox(height: 20),

          CyberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CyberSectionLabel(label: 'Módulo a exportar'),
                const SizedBox(height: 8),
                _ModuloGrid(seleccionado: _modulo, onChanged: _onModuloChanged),

                const SizedBox(height: 24),
                const CyberSectionLabel(label: 'Formato de descarga'),
                const SizedBox(height: 8),
                _FormatoSelector(
                  formatos:  formatos,
                  seleccionado: _formato,
                  onChanged: (f) => setState(() => _formato = f),
                ),
                if (_modulo.soloExcel) ...[
                  const SizedBox(height: 10),
                  _InfoNote(
                    icon: Icons.layers_outlined,
                    text: 'La base de datos completa incluye una hoja por '
                        'módulo, por eso solo está disponible en Excel.',
                  ),
                ],

                if (campos.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(
                        child: CyberSectionLabel(label: 'Filtros opcionales'),
                      ),
                      if (_filtrosActivos > 0)
                        _FiltrosActivosChip(count: _filtrosActivos),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _FiltrosGrid(
                    campos:        campos,
                    controllers:   _controllers,
                    seleccionados: _seleccionados,
                    onChanged:     () => setState(() {}),
                  ),
                ],

                const SizedBox(height: 28),
                CyberButton(
                  label:     isExporting ? 'Generando archivo…' : 'Descargar archivo',
                  loading:   isExporting,
                  onPressed: _exportar,
                ),
              ],
            ),
          ),

          if (provider.hasExportError) ...[
            const SizedBox(height: 16),
            CyberErrorBanner(message: provider.exportError),
          ],
          if (provider.exportSuccess && provider.lastResult != null) ...[
            const SizedBox(height: 16),
            _ExportSuccessCard(result: provider.lastResult!),
          ],
        ],
      ),
    );
  }
}

// ── Encabezado ─────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final TipoExportacion modulo;
  const _Header({required this.modulo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Icon(_iconoModulo(modulo), color: AppTheme.primary, size: 24),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exportación de datos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Genera reportes reales de tu institución en Excel o CSV',
                style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

IconData _iconoModulo(TipoExportacion m) {
  switch (m) {
    case TipoExportacion.fichas:       return Icons.badge_outlined;
    case TipoExportacion.estudiantes:  return Icons.school_outlined;
    case TipoExportacion.docentes:     return Icons.person_outline;
    case TipoExportacion.horarios:     return Icons.calendar_month_outlined;
    case TipoExportacion.aulas:        return Icons.meeting_room_outlined;
    case TipoExportacion.planes:       return Icons.event_note_outlined;
    case TipoExportacion.competencias: return Icons.workspace_premium_outlined;
    case TipoExportacion.analitica:    return Icons.insights_outlined;
    case TipoExportacion.completa:     return Icons.dns_outlined;
  }
}

// ── Selector de módulo (grid de chips en vez de un dropdown plano) ─────────

class _ModuloGrid extends StatelessWidget {
  final TipoExportacion            seleccionado;
  final ValueChanged<TipoExportacion?> onChanged;

  const _ModuloGrid({required this.seleccionado, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TipoExportacion.values.map((t) {
        final selected = t == seleccionado;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppTheme.primary.withOpacity(0.14)
                  : const Color(0xFF010C12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppTheme.primary : AppTheme.border,
                width: selected ? 1.4 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _iconoModulo(t),
                  size: 16,
                  color: selected ? AppTheme.primary : AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  t.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Selector de formato ─────────────────────────────────────────────────────

class _FormatoSelector extends StatelessWidget {
  final List<FormatoExportacion>       formatos;
  final FormatoExportacion             seleccionado;
  final ValueChanged<FormatoExportacion> onChanged;

  const _FormatoSelector({
    required this.formatos,
    required this.seleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: formatos.map((f) {
        final selected = f == seleccionado;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: f == formatos.last ? 0 : 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onChanged(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primary.withOpacity(0.14)
                      : const Color(0xFF010C12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? AppTheme.primary : AppTheme.border,
                    width: selected ? 1.4 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      f == FormatoExportacion.excel
                          ? Icons.grid_on_rounded
                          : Icons.description_outlined,
                      size: 20,
                      color: selected ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      f.label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? AppTheme.primary : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Grid de filtros (2 columnas en pantallas anchas) ────────────────────────

class _FiltrosGrid extends StatelessWidget {
  final List<FiltroCampo>                  campos;
  final Map<String, TextEditingController> controllers;
  final Map<String, String>                seleccionados;
  final VoidCallback                       onChanged;

  const _FiltrosGrid({
    required this.campos,
    required this.controllers,
    required this.seleccionados,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dosColumnas = constraints.maxWidth > 480;
        final ancho = dosColumnas
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: campos.map((campo) {
            return SizedBox(width: ancho, child: _campoWidget(campo));
          }).toList(),
        );
      },
    );
  }

  Widget _campoWidget(FiltroCampo campo) {
    if (campo.esSelect) {
      return DropdownButtonFormField<String>(
        value: seleccionados[campo.key] ?? '',
        isExpanded: true,
        decoration: InputDecoration(labelText: campo.label),
        items: campo.opciones!
            .map((o) => DropdownMenuItem(
                  value: o.key,
                  child: Text(o.value, overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: (v) {
          seleccionados[campo.key] = v ?? '';
          onChanged();
        },
      );
    }

    final controller = controllers.putIfAbsent(
      campo.key,
      () => TextEditingController(),
    );
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: campo.label, hintText: campo.hint),
      onChanged: (_) => onChanged(),
    );
  }
}

// ── Chip contador de filtros activos ────────────────────────────────────────

class _FiltrosActivosChip extends StatelessWidget {
  final int count;
  const _FiltrosActivosChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withOpacity(0.5)),
      ),
      child: Text(
        '$count activo${count == 1 ? '' : 's'}',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.accent,
        ),
      ),
    );
  }
}

// ── Nota informativa ─────────────────────────────────────────────────────────

class _InfoNote extends StatelessWidget {
  final IconData icon;
  final String   text;
  const _InfoNote({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de éxito con detalle del archivo generado ───────────────────────

class _ExportSuccessCard extends StatelessWidget {
  final ExportResult result;
  const _ExportSuccessCard({required this.result});

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppTheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.fileName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatBytes(result.sizeBytes),
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
