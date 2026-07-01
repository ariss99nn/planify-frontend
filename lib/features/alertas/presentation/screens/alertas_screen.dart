import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/alertas_provider.dart';
import '../widgets/alerta_card.dart';
import '../widgets/alerta_filter_chips.dart';
import '../widgets/cyber_status_badge.dart';

class AlertasScreen extends StatefulWidget {
  /// Id del usuario autenticado.
  /// Idealmente vendría de un AuthProvider global; se mantiene como
  /// parámetro para no acoplar este módulo al módulo de autenticación.
  final int currentUserId;

  const AlertasScreen({super.key, required this.currentUserId});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Carga inicial en el próximo frame para que el Provider ya esté montado.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertasProvider>().cargar();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context.read<AlertasProvider>().cargarMas();
    }
  }

  Future<void> _marcarLeida(AlertasProvider provider, alerta) async {
    final error = await provider.marcarLeida(alerta, widget.currentUserId);
    if (error != null && mounted) {
      CyberSnackbar.error(context, error);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Selector fino: solo reconstruye el AppBar cuando cambia noLeidas.
    final noLeidas = context.select<AlertasProvider, int>((p) => p.noLeidas);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ALERTAS',
          style: TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
        actions: [
          if (noLeidas > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: CyberStatusBadge(
                  label: '$noLeidas nuevas',
                  color: AppTheme.primary,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Selector fino: solo reconstruye los chips cuando cambian filtros.
          Selector<AlertasProvider, (String?, String?)>(
            selector: (_, p) => (p.filtroEstado, p.filtroTipo),
            builder: (_, filtros, __) => AlertaFilterChips(
              filtroEstado: filtros.$1,
              filtroTipo: filtros.$2,
              onFiltrosChanged: (estado, tipo) =>
                  context.read<AlertasProvider>().aplicarFiltros(
                        estado: estado,
                        tipo: tipo,
                      ),
            ),
          ),
          const Expanded(child: _AlertasList()),
        ],
      ),
    );
  }
}

/// Widget separado para la lista: se reconstruye independientemente del AppBar.
class _AlertasList extends StatelessWidget {
  const _AlertasList();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertasProvider>();

    return switch (provider.status) {
      AlertasStatus.initial ||
      AlertasStatus.loading =>
        const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      AlertasStatus.error => CyberErrorView(
          message: provider.errorMessage ?? 'Error desconocido.',
          onRetry: () => context.read<AlertasProvider>().cargar(),
        ),
      AlertasStatus.loaded || AlertasStatus.loadingMore => _buildList(
          context,
          provider,
        ),
    };
  }

  Widget _buildList(BuildContext context, AlertasProvider provider) {
    final hoy = provider.alertasHoy;
    final anteriores = provider.alertasAnteriores;

    if (hoy.isEmpty && anteriores.isEmpty) {
      return const CyberEmptyView(
        icon: Icons.notifications_none_rounded,
        title: 'Sin alertas',
        subtitle: 'No hay alertas con los filtros actuales',
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AlertasProvider>().cargar(),
      color: AppTheme.primary,
      child: CustomScrollView(
        controller: context
            .findAncestorStateOfType<_AlertasScreenState>()
            ?._scrollController,
        slivers: [
          if (hoy.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: CyberSectionLabel(label: 'Hoy'),
            ),
            SliverList.builder(
              itemCount: hoy.length,
              itemBuilder: (_, i) => AlertaCard(
                alerta: hoy[i],
                onTap: () => context
                    .findAncestorStateOfType<_AlertasScreenState>()
                    ?._marcarLeida(provider, hoy[i]),
              ),
            ),
          ],
          if (anteriores.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: CyberSectionLabel(label: 'Anteriores'),
            ),
            SliverList.builder(
              itemCount: anteriores.length,
              itemBuilder: (_, i) => AlertaCard(
                alerta: anteriores[i],
                onTap: () => context
                    .findAncestorStateOfType<_AlertasScreenState>()
                    ?._marcarLeida(provider, anteriores[i]),
              ),
            ),
          ],
          if (provider.status == AlertasStatus.loadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          if (provider.errorPaginacion)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => context.read<AlertasProvider>().cargarMas(),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reintentar carga'),
                  ),
                ),
              ),
            ),
          // Padding inferior para que el último item no quede pegado.
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }
}
