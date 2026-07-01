// lib/features/aulas/presentation/widgets/views/bloque_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../domain/entities/bloque_entity.dart';
import '../../providers/bloque_provider.dart';
import 'bloque_detail_view.dart';
import 'bloque_form_view.dart';

const _estados = [
  ('ACT',  'Activo'),
  ('MANT', 'Mantenimiento'),
  ('INAC', 'Inactivo'),
];

class BloqueListView extends StatefulWidget {
  final bool canWrite;
  const BloqueListView({required this.canWrite, super.key});

  @override
  State<BloqueListView> createState() => _BloqueListViewState();
}

class _BloqueListViewState extends State<BloqueListView>
    with AutomaticKeepAliveClientMixin {
  final _searchCtrl = TextEditingController();
  String? _estadoFiltro;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<BloqueProvider>().fetchBloques());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFiltros() => context.read<BloqueProvider>().setFiltros(
        search: _searchCtrl.text.trim(),
        estado: _estadoFiltro,
      );

  void _clearFiltros() {
    _searchCtrl.clear();
    setState(() => _estadoFiltro = null);
    context.read<BloqueProvider>().clearFiltros();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // requerido por AutomaticKeepAliveClientMixin
    return Column(
      children: [
        _FiltrosBar(
          searchCtrl:      _searchCtrl,
          estadoFiltro:    _estadoFiltro,
          onEstadoChanged: (v) => setState(() => _estadoFiltro = v),
          onApply:         _applyFiltros,
          onClear:         _clearFiltros,
        ),
        Expanded(child: _BloqueListBody(canWrite: widget.canWrite)),
      ],
    );
  }
}

class _FiltrosBar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final String? estadoFiltro;
  final ValueChanged<String?> onEstadoChanged;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const _FiltrosBar({
    required this.searchCtrl,
    required this.estadoFiltro,
    required this.onEstadoChanged,
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
            hint: 'Buscar por nombre…',
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

class _BloqueListBody extends StatelessWidget {
  final bool canWrite;
  const _BloqueListBody({required this.canWrite});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BloqueProvider>();

    return switch (provider.listStatus) {
      BloqueStatus.idle    => const SizedBox.shrink(),
      BloqueStatus.loading => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary)),
      BloqueStatus.error => CyberErrorView(
          message: provider.listError ?? 'Error desconocido',
          onRetry: () => context.read<BloqueProvider>().fetchBloques(),
        ),
      BloqueStatus.success when provider.bloques.isEmpty => const CyberEmptyView(
          icon: Icons.domain_outlined,
          title: 'No hay bloques',
          subtitle: 'Prueba ajustando los filtros',
        ),
      _ => NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
              context.read<BloqueProvider>().loadMoreBloques();
            }
            return true;
          },
          child: RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () => context.read<BloqueProvider>().fetchBloques(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.bloques.length + (provider.hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                if (i >= provider.bloques.length) {
                  return const _LoadMoreIndicator();
                }
                return _BloqueCard(bloque: provider.bloques[i], canWrite: canWrite);
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

class _BloqueCard extends StatelessWidget {
  final BloqueResumenEntity bloque;
  final bool canWrite;
  const _BloqueCard({required this.bloque, required this.canWrite});

  void _openEditForm(BuildContext context) async {
    final provider = context.read<BloqueProvider>();
    await provider.fetchBloque(bloque.id);
    if (!context.mounted) return;
    final full = provider.selected;
    if (full == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BloqueFormView(bloque: full)),
    );
    if (context.mounted) provider.fetchBloques();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BloqueDetailView(bloqueId: bloque.id)),
        ).then((_) => context.read<BloqueProvider>().fetchBloques()),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.domain, color: AppTheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bloque.nombre,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.layers_outlined, size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text('${bloque.pisos} piso${bloque.pisos != 1 ? 's' : ''}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        const SizedBox(width: 10),
                        const Icon(Icons.people_outline, size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text('Cap. ${bloque.capacidadMaxima}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        const SizedBox(width: 10),
                        CyberEstadoBadge.fromCodigo(bloque.estado, bloque.estadoDisplay),
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