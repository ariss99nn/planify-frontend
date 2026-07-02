import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

import '../../../../../core/widgets/cyber_button.dart';
import '../../../../../core/widgets/cyber_section_label.dart';
import '../../../../../core/widgets/cyber_snackbar.dart';
import '../../config/filtros_modulo.dart';
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

  final Map<String, TextEditingController> _controllers  = {};
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

  void _onModuloChanged(TipoExportacion? nuevo) {
    if (nuevo == null) return;
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
  }

  Future<void> _exportar() async {
    final provider = context.read<ExportacionProvider>();
    await provider.exportar(
      modulo:  _modulo,
      formato: _formato,
      filtros: _filtrosActuales,
    );

    if (!mounted) return;

    if (provider.exportSuccess && provider.lastFile != null) {
      CyberSnackbar.success(context, 'Archivo descargado correctamente');
      await OpenFilex.open(provider.lastFile!.path);
      provider.resetExport();
    } else if (provider.hasExportError) {
      CyberSnackbar.error(
        context,
        provider.exportError ?? 'Error al exportar',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExporting = context.watch<ExportacionProvider>().isExporting;
    final campos      = kFiltrosPorModulo[_modulo] ?? const [];
    final formatos    = _modulo.soloExcel
        ? [FormatoExportacion.excel]
        : FormatoExportacion.values;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<TipoExportacion>(
            value: _modulo,
            decoration: const InputDecoration(labelText: 'Módulo a exportar'),
            items: TipoExportacion.values
                .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                .toList(),
            onChanged: _onModuloChanged,
          ),
          const SizedBox(height: 20),
          const CyberSectionLabel(label: 'Formato de descarga'),
          const SizedBox(height: 8),
          SegmentedButton<FormatoExportacion>(
            segments: formatos
                .map((f) => ButtonSegment(value: f, label: Text(f.label)))
                .toList(),
            selected: {_formato},
            onSelectionChanged: (s) => setState(() => _formato = s.first),
          ),
          if (_modulo.soloExcel) ...[
            const SizedBox(height: 8),
            Text(
              'La base de datos completa incluye una hoja por módulo, '
              'por eso solo está disponible en Excel.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (campos.isNotEmpty) ...[
            const SizedBox(height: 24),
            const CyberSectionLabel(label: 'Filtros opcionales'),
            const SizedBox(height: 8),
            ...campos.map(_buildCampo),
          ],
          const SizedBox(height: 24),
          CyberButton(
            label:     'Descargar archivo',
            loading:   isExporting,
            onPressed: _exportar,
          ),
        ],
      ),
    );
  }

  Widget _buildCampo(FiltroCampo campo) {
    if (campo.esSelect) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          value: _seleccionados[campo.key] ?? '',
          decoration: InputDecoration(labelText: campo.label),
          items: campo.opciones!
              .map((o) => DropdownMenuItem(value: o.key, child: Text(o.value)))
              .toList(),
          onChanged: (v) =>
              setState(() => _seleccionados[campo.key] = v ?? ''),
        ),
      );
    }

    final controller =
        _controllers.putIfAbsent(campo.key, () => TextEditingController());
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration:
            InputDecoration(labelText: campo.label, hintText: campo.hint),
      ),
    );
  }
}
