import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/widgets/cyber_dropdown_filter.dart';
import '../../../../../core/widgets/cyber_empty_view.dart';
import '../../../../../core/widgets/cyber_error_view.dart';
import '../../../../../core/widgets/cyber_loading_view.dart';
import '../../../domain/entities/exportacion_enums.dart';
import '../../providers/exportacion_provider.dart';
import '../registro_tile.dart';

class HistorialView extends StatefulWidget {
  const HistorialView({super.key});

  @override
  State<HistorialView> createState() => _HistorialViewState();
}

class _HistorialViewState extends State<HistorialView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExportacionProvider>().cargarLog(reiniciar: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExportacionProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: CyberDropdownFilter<TipoExportacion>(
                  hint:      'Filtrar por módulo',
                  value:     provider.filtroTipo,
                  allLabel:  'Todos',
                  items: TipoExportacion.values
                      .map((t) => (t, t.label))
                      .toList(),
                  onChanged: provider.setFiltroTipo,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Actualizar',
                onPressed: () => provider.cargarLog(reiniciar: true),
              ),
            ],
          ),
        ),
        if (provider.isLoadingLog)
          const Expanded(
            child: CyberLoadingView(mensaje: 'Cargando historial…'),
          )
        else if (provider.logError != null)
          Expanded(
            child: CyberErrorView(
              message:  provider.logError!,
              onRetry:  () => provider.cargarLog(reiniciar: true),
            ),
          )
        else if (provider.logs.isEmpty)
          const Expanded(
            child: CyberEmptyView(
              icon:     Icons.history_rounded,
              title:    'Sin exportaciones registradas',
              subtitle: 'Aún no se han realizado exportaciones.',
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount:       provider.logs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) =>
                  RegistroTile(registro: provider.logs[i]),
            ),
          ),
        if (provider.totalPages > 1)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon:      const Icon(Icons.chevron_left_rounded),
                  onPressed: provider.logPage > 1
                      ? provider.paginaAnterior
                      : null,
                ),
                Text('${provider.logPage} / ${provider.totalPages}'),
                IconButton(
                  icon:      const Icon(Icons.chevron_right_rounded),
                  onPressed: provider.logPage < provider.totalPages
                      ? provider.paginaSiguiente
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
