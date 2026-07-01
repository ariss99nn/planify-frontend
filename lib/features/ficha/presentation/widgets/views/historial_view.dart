// lib/features/ficha/presentation/widgets/views/historial_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/cyber_loading_view.dart';
import '../../../../../core/widgets/cyber_empty_view.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../providers/ficha_provider.dart';
import '../../../domain/entities/ficha_entity.dart';

class HistorialView extends StatefulWidget {
  const HistorialView({super.key});

  @override
  State<HistorialView> createState() => _HistorialViewState();
}

class _HistorialViewState extends State<HistorialView> {
  final _scrollCtrl = ScrollController();

  String? _filtroEtapaNueva;
  String? _filtroEtapaAnterior;

  static const _etapas = {
    'LECTIVA': 'Lectiva',
    'PRODUCTIVA': 'Productiva',
  };

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    Future.microtask(_cargar);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<FichaProvider>().fetchMasHistorial();
    }
  }

  Future<void> _cargar() async {
    await context.read<FichaProvider>().fetchHistorial(
          etapaNueva:    _filtroEtapaNueva,
          etapaAnterior: _filtroEtapaAnterior,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isManager = context.read<AuthProvider>().puedeGestionarUsuarios;

    if (!isManager) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 48, color: AppTheme.textSecondary),
            SizedBox(height: 12),
            Text('Solo coordinadores pueden ver el historial global.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    final provider = context.watch<FichaProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: _FiltroDropdown(
                  label:    'De etapa',
                  valor:    _filtroEtapaAnterior,
                  opciones: _etapas,
                  onChanged: (v) {
                    setState(() => _filtroEtapaAnterior = v);
                    _cargar();
                  },
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: AppTheme.textSecondary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: _FiltroDropdown(
                  label:    'A etapa',
                  valor:    _filtroEtapaNueva,
                  opciones: _etapas,
                  onChanged: (v) {
                    setState(() => _filtroEtapaNueva = v);
                    _cargar();
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.primary),
                onPressed: _cargar,
              ),
            ],
          ),
        ),

        if (!provider.loadingHistorial && provider.historial.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${provider.totalHistorial} registros',
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withOpacity(0.6)),
              ),
            ),
          ),

        if (provider.loadingHistorial && provider.historial.isEmpty)
          const Expanded(
              child: CyberLoadingView(mensaje: 'Cargando historial…'))
        else if (provider.historialError != null &&
            provider.historial.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(provider.historialError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _cargar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          )
        else if (provider.historial.isEmpty)
          const Expanded(
            child: CyberEmptyView(
              icon: Icons.history_toggle_off,
              title: 'Sin registros de historial',
              subtitle: 'Prueba con otros filtros',
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: _cargar,
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                itemCount: provider.historial.length +
                    (provider.hayMasPaginasHistorial ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == provider.historial.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _HistorialCard(item: provider.historial[i]);
                },
              ),
            ),
          ),
      ],
    );
  }
}

// ── _HistorialCard ─────────────────────────────────────────────────────────────

class _HistorialCard extends StatelessWidget {
  final HistorialEtapaEntity item;
  const _HistorialCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final fecha =
        '${item.fecha.day.toString().padLeft(2, '0')}/'
        '${item.fecha.month.toString().padLeft(2, '0')}/${item.fecha.year}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _EtapaBadge(
                label: item.etapaAnteriorDisplay,
                color: AppTheme.textSecondary,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward,
                    size: 14, color: AppTheme.primary),
              ),
              _EtapaBadge(
                label: item.etapaNuevaDisplay,
                color: AppTheme.primary,
              ),
              const Spacer(),
              Text(fecha,
                  style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary.withOpacity(0.6))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.tag, size: 12, color: AppTheme.accent),
              const SizedBox(width: 4),
              Text(item.fichaCodigo,
                  style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              Icon(Icons.calendar_view_month_outlined,
                  size: 12,
                  color: AppTheme.textSecondary.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text('T${item.trimestre}',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withOpacity(0.5))),
            ],
          ),
          if (item.cambiadoPorNombre != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 12,
                    color: AppTheme.textSecondary.withOpacity(0.4)),
                const SizedBox(width: 4),
                Text('Por: ${item.cambiadoPorNombre}',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary.withOpacity(0.4))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EtapaBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _EtapaBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _FiltroDropdown extends StatelessWidget {
  final String label;
  final String? valor;
  final Map<String, String> opciones;
  final ValueChanged<String?> onChanged;

  const _FiltroDropdown({
    required this.label,
    required this.valor,
    required this.opciones,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: valor,
      dropdownColor: AppTheme.surface,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text('Todos',
              style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7),
                  fontSize: 13)),
        ),
        ...opciones.entries.map((e) =>
            DropdownMenuItem(value: e.key, child: Text(e.value))),
      ],
      onChanged: onChanged,
    );
  }
}
