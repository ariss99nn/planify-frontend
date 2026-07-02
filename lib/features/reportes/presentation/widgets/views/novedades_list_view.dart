import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/cyber_empty_view.dart';
import '../../../../../core/widgets/cyber_error_view.dart';
import '../../../../../core/widgets/cyber_loading_view.dart';
import '../../../domain/entities/novedad_entity.dart';
import '../../providers/novedad_provider.dart';
import '../atender_novedad_dialog.dart';
import '../novedad_card.dart';
import '../novedad_detail_dialog.dart';

class NovedadesListView extends StatefulWidget {
  const NovedadesListView({
    super.key,
    required this.onCrear,
  });

  final VoidCallback onCrear;

  @override
  State<NovedadesListView> createState() => _NovedadesListViewState();
}

class _NovedadesListViewState extends State<NovedadesListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NovedadProvider>().cargarMas();
    }
  }

  Future<void> _abrirNovedad(NovedadEntity novedad) async {
    final provider = context.read<NovedadProvider>();
    if (novedad.atendida) {
      await NovedadDetailDialog.mostrar(context, novedad);
      return;
    }
    await AtenderNovedadDialog.mostrar(
      context,
      novedad: novedad,
      provider: provider,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NovedadProvider>();

    // IMPORTANTE — corrección de bug: este widget se embebe como `body`
    // dentro del Scaffold de ReportesGestionScreen, que ya dibuja su propio
    // AppBar ("Novedades") y su NavigationBar inferior. Envolver este
    // contenido en OTRO Scaffold con OTRO AppBar producía dos barras de
    // título apiladas verticalmente — de ahí la sensación de paneles
    // invasivos. Ahora solo se devuelve el contenido (filtros + lista) y
    // el botón de "Nueva" se posiciona con un Stack en vez de depender de
    // un Scaffold propio.
    return Stack(
      children: [
        RefreshIndicator(
          color: AppTheme.primary,
          backgroundColor: AppTheme.surface,
          onRefresh: provider.cargarInicial,
          child: Column(
            children: [
              _FiltrosBar(provider: provider),
              Expanded(child: _buildContenido(provider)),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: widget.onCrear,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nueva'),
          ),
        ),
      ],
    );
  }

  Widget _buildContenido(NovedadProvider provider) {
    if (provider.cargando) {
      return const CyberLoadingView(mensaje: 'Cargando novedades…');
    }

    if (provider.error != null && provider.novedades.isEmpty) {
      return CyberErrorView(
        message: provider.error!,
        onRetry: provider.cargarInicial,
      );
    }

    if (provider.novedades.isEmpty) {
      final esFiltroPendientes =
          provider.filtroEstado == NovedadFiltroEstado.pendientes;
      return CyberEmptyView(
        icon: Icons.fact_check_outlined,
        title: esFiltroPendientes
            ? 'No hay novedades pendientes'
            : 'No hay novedades en este filtro',
        message: esFiltroPendientes
            ? 'Todo está bajo control por ahora.'
            : 'Prueba con otro filtro o crea una novedad manual.',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount:
          provider.novedades.length + (provider.cargandoMas ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= provider.novedades.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primary,
                ),
              ),
            ),
          );
        }
        final novedad = provider.novedades[index];
        return NovedadCard(
          novedad: novedad,
          onTap: () => _abrirNovedad(novedad),
        );
      },
    );
  }
}

class _FiltrosBar extends StatelessWidget {
  const _FiltrosBar({required this.provider});

  final NovedadProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: NovedadFiltroEstado.values.map((estado) {
              final seleccionado = provider.filtroEstado == estado;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_labelFiltro(estado)),
                  selected: seleccionado,
                  onSelected: (_) => provider.cambiarFiltroEstado(estado),
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.surfaceLight,
                  labelStyle: TextStyle(
                    color: seleccionado ? Colors.black : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<NovedadTipo?>(
              value: provider.filtroTipo,
              hint: const Text('Todos los tipos'),
              isDense: true,
              dropdownColor: AppTheme.surface,
              items: [
                const DropdownMenuItem<NovedadTipo?>(
                  value: null,
                  child: Text('Todos los tipos'),
                ),
                ...NovedadTipo.values.map(
                  (t) => DropdownMenuItem<NovedadTipo?>(
                      value: t, child: Text(t.label)),
                ),
              ],
              onChanged: provider.cambiarFiltroTipo,
            ),
          ),
        ],
      ),
    );
  }

  String _labelFiltro(NovedadFiltroEstado estado) {
    switch (estado) {
      case NovedadFiltroEstado.todas:
        return 'Todas';
      case NovedadFiltroEstado.pendientes:
        return 'Pendientes';
      case NovedadFiltroEstado.atendidas:
        return 'Atendidas';
    }
  }
}
