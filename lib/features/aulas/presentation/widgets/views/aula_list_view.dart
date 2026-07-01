// lib/features/aulas/presentation/widgets/views/aula_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../domain/entities/aula_entity.dart';
import '../../providers/aula_provider.dart';
import '../views/aula_form_view.dart';
import '../views/aula_detail_view.dart';

const _estados = [
  ('ACT',  'Activa'),
  ('MANT', 'Mantenimiento'),
  ('INAC', 'Inactiva'),
];

const _tipos = [
  ('LAB', 'Laboratorio'),
  ('TEO', 'Teórica'),
  ('SIS', 'Sistemas'),
  ('OTR', 'Otro'),
];

class AulaListView extends StatefulWidget {
  final bool canWrite;
  const AulaListView({required this.canWrite, super.key});

  @override
  State<AulaListView> createState() => _AulaListViewState();
}

class _AulaListViewState extends State<AulaListView>
    with AutomaticKeepAliveClientMixin {
  final _searchCtrl = TextEditingController();
  String? _estadoFiltro;
  String? _tipoFiltro;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AulaProvider>().fetchAulas());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFiltros() => context.read<AulaProvider>().setFiltros(
        search: _searchCtrl.text.trim(),
        estado: _estadoFiltro,
        tipo:   _tipoFiltro,
      );

  void _clearFiltros() {
    _searchCtrl.clear();
    setState(() { _estadoFiltro = null; _tipoFiltro = null; });
    context.read<AulaProvider>().clearFiltros();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // requerido por AutomaticKeepAliveClientMixin
    return Column(
      children: [
        _FiltrosBar(
          searchCtrl:      _searchCtrl,
          estadoFiltro:    _estadoFiltro,
          tipoFiltro:      _tipoFiltro,
          onEstadoChanged: (v) => setState(() => _estadoFiltro = v),
          onTipoChanged:   (v) => setState(() => _tipoFiltro   = v),
          onApply:         _applyFiltros,
          onClear:         _clearFiltros,
        ),
        Expanded(child: _AulaListBody(canWrite: widget.canWrite)),
      ],
    );
  }
}

class _FiltrosBar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final String? estadoFiltro;
  final String? tipoFiltro;
  final ValueChanged<String?> onEstadoChanged;
  final ValueChanged<String?> onTipoChanged;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const _FiltrosBar({
    required this.searchCtrl,
    required this.estadoFiltro,
    required this.tipoFiltro,
    required this.onEstadoChanged,
    required this.onTipoChanged,
    required this.onApply,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface.withOpacity(0.6),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          CyberSearchBar(
            controller: searchCtrl,
            hint: 'Buscar por código, bloque o descripción…',
            onSubmitted: (_) => onApply(),
            onClear: () { searchCtrl.clear(); onApply(); },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CyberDropdownFilter<String>(
                  hint: 'Estado',
                  value: estadoFiltro,
                  items: _estados.toList(),
                  onChanged: onEstadoChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CyberDropdownFilter<String>(
                  hint: 'Tipo',
                  value: tipoFiltro,
                  items: _tipos.toList(),
                  onChanged: onTipoChanged,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  minimumSize: const Size(0, 0),
                ),
                child: const Text('Filtrar'),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                tooltip: 'Limpiar filtros',
                onPressed: onClear,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AulaListBody extends StatelessWidget {
  final bool canWrite;
  const _AulaListBody({required this.canWrite});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AulaProvider>();

    return switch (provider.listStatus) {
      AulaStatus.idle    => const SizedBox.shrink(),
      AulaStatus.loading => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      AulaStatus.error => CyberErrorView(
          message: provider.listError ?? 'Error desconocido',
          onRetry: () => context.read<AulaProvider>().fetchAulas(),
        ),
      AulaStatus.success when provider.aulas.isEmpty => const CyberEmptyView(
          icon: Icons.meeting_room_outlined,
          title: 'No hay aulas',
          subtitle: 'Prueba ajustando los filtros',
        ),
      _ => NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
              context.read<AulaProvider>().loadMoreAulas();
            }
            return true;
          },
          child: RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () => context.read<AulaProvider>().fetchAulas(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.aulas.length + (provider.hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                if (i >= provider.aulas.length) {
                  return const _LoadMoreIndicator();
                }
                return _AulaCard(aula: provider.aulas[i], canWrite: canWrite);
              },
            ),
          ),
        ),
    };
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.4, color: AppTheme.primary),
        ),
      ),
    );
  }
}

class _AulaCard extends StatelessWidget {
  final AulaResumenEntity aula;
  final bool canWrite;
  const _AulaCard({required this.aula, required this.canWrite});

  void _openEditForm(BuildContext context) async {
    final provider = context.read<AulaProvider>();
    await provider.fetchAula(aula.id);
    if (!context.mounted) return;
    final full = provider.selected;
    if (full == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AulaFormView(aula: full)),
    );
    if (context.mounted) provider.fetchAulas();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AulaDetailView(aulaId: aula.id),
          ),
        ).then((_) => context.read<AulaProvider>().fetchAulas()),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.meeting_room, color: AppTheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(aula.codigoAula,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        )),
                    const SizedBox(height: 2),
                    Text(
                      '${aula.bloqueNombre} · ${aula.tipoAulaDisplay}',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.people_outline, size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text('${aula.capacidad} personas',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        const SizedBox(width: 10),
                        CyberEstadoBadge.fromCodigo(aula.estado, aula.estadoDisplay),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              if (canWrite)
                CyberActionButton(
                  icon: Icons.edit_outlined,
                  color: AppTheme.primary,
                  tooltip: 'Editar',
                  onTap: () => _openEditForm(context),
                )
              else
                const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}