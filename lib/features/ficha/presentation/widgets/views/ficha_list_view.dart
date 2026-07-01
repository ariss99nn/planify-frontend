// lib/features/ficha/presentation/widgets/views/ficha_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/cyber_loading_view.dart';
import '../../../../../core/widgets/cyber_empty_view.dart';
import '../../providers/ficha_provider.dart';
import '../../../domain/entities/ficha_entity.dart';
import 'ficha_detail_view.dart';
import 'ficha_create_view.dart';

class FichaListView extends StatefulWidget {
  final bool canWrite;
  const FichaListView({super.key, required this.canWrite});

  @override
  State<FichaListView> createState() => _FichaListViewState();
}

class _FichaListViewState extends State<FichaListView> {
  final _searchCtrl  = TextEditingController();
  final _scrollCtrl  = ScrollController();

  String? _filtroEtapa;
  String? _filtroJornada;
  String? _filtroEstado;
  bool?   _filtroCadena;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<FichaProvider>().fetchFichas());
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<FichaProvider>().fetchMasFichas();
    }
  }

  void _applyFilters() {
    context.read<FichaProvider>().fetchFichas(
      search:          _searchCtrl.text,
      etapa:           _filtroEtapa,
      jornada:         _filtroJornada,
      estado:          _filtroEstado,
      cadenaFormacion: _filtroCadena,
    );
  }

  int get _filtrosActivos => [
        _filtroEtapa,
        _filtroJornada,
        _filtroEstado,
        if (_filtroCadena != null) 'x',
      ].where((e) => e != null).length;

  void _showFiltros() {
    String? etapa   = _filtroEtapa;
    String? jornada = _filtroJornada;
    String? estado  = _filtroEstado;
    bool?   cadena  = _filtroCadena;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('FILTROS',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                    fontSize: 13,
                  )),
              const SizedBox(height: 20),
              _FiltroChips(
                label: 'Etapa',
                opciones: const {'LECTIVA': 'Lectiva', 'PRODUCTIVA': 'Productiva'},
                seleccionado: etapa,
                onSelected: (v) => setModal(() => etapa = v),
              ),
              const SizedBox(height: 16),
              _FiltroChips(
                label: 'Jornada',
                opciones: const {
                  'MANANA': 'Mañana',
                  'TARDE': 'Tarde',
                  'NOCHE': 'Noche',
                  'MIXTA': 'Mixta',
                },
                seleccionado: jornada,
                onSelected: (v) => setModal(() => jornada = v),
              ),
              const SizedBox(height: 16),
              _FiltroChips(
                label: 'Estado',
                opciones: const {
                  'ACTIVA': 'Activa',
                  'INACTIVA': 'Inactiva',
                  'CERRADA': 'Cerrada',
                },
                seleccionado: estado,
                onSelected: (v) => setModal(() => estado = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Cadena de formación',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const Spacer(),
                  _TriSwitch(
                    value: cadena,
                    onChanged: (v) => setModal(() => cadena = v),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setModal(() {
                        etapa = jornada = estado = null;
                        cadena = null;
                      }),
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filtroEtapa   = etapa;
                          _filtroJornada = jornada;
                          _filtroEstado  = estado;
                          _filtroCadena  = cadena;
                        });
                        Navigator.pop(ctx);
                        _applyFilters();
                      },
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetalle(FichaListEntity ficha) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FichaDetailView(fichaId: ficha.id)),
    ).then((_) {
      if (!mounted) return;
      context.read<FichaProvider>().fetchFichas(search: _searchCtrl.text);
    });
  }

  void _openCrear() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FichaCreateView()),
    ).then((_) {
      if (!mounted) return;
      context.read<FichaProvider>().fetchFichas(search: _searchCtrl.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FichaProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border.withOpacity(0.5)),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Buscar por código o programa...',
                      hintStyle: TextStyle(
                          color: AppTheme.textSecondary.withOpacity(0.5)),
                      prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear,
                            color: _searchCtrl.text.isEmpty
                                ? AppTheme.textSecondary.withOpacity(0.3)
                                : AppTheme.primary),
                        onPressed: () {
                          if (_searchCtrl.text.isNotEmpty) {
                            _searchCtrl.clear();
                            _applyFilters();
                          }
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: (_) => _applyFilters(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.tune, color: AppTheme.primary),
                    onPressed: _showFiltros,
                  ),
                  if (_filtrosActivos > 0)
                    Positioned(
                      right: 8, top: 8,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(
                            color: AppTheme.primary, shape: BoxShape.circle),
                        child: Center(
                          child: Text('$_filtrosActivos',
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.primary),
                onPressed: () => context
                    .read<FichaProvider>()
                    .fetchFichas(search: _searchCtrl.text),
              ),
            ],
          ),
        ),

        if (!provider.loadingFichas && provider.fichas.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${provider.totalFichas} fichas encontradas',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary.withOpacity(0.6),
                ),
              ),
            ),
          ),

        if (provider.loadingFichas && provider.fichas.isEmpty)
          const Expanded(child: CyberLoadingView(mensaje: 'Cargando fichas…'))
        else if (provider.fichasError != null && provider.fichas.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(provider.fichasError!,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _applyFilters,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          )
        else if (provider.fichas.isEmpty)
          const Expanded(
            child: CyberEmptyView(
              icon: Icons.folder_open,
              title: 'No hay fichas',
              subtitle: 'Prueba con otra búsqueda o filtro',
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () => context
                  .read<FichaProvider>()
                  .fetchFichas(search: _searchCtrl.text),
              child: ListView.builder(
                controller: _scrollCtrl,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount:
                    provider.fichas.length + (provider.hayMasPaginas ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == provider.fichas.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final ficha = provider.fichas[i];
                  return _FichaCard(
                    ficha: ficha,
                    onTap: () => _openDetalle(ficha),
                  );
                },
              ),
            ),
          ),

        if (widget.canWrite)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FloatingActionButton.extended(
                heroTag: 'fab_fichas',
                onPressed: _openCrear,
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
                icon: const Icon(Icons.add),
                label: const Text('Nueva ficha',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
      ],
    );
  }
}

// ── _FichaCard ─────────────────────────────────────────────────────────────────

class _FichaCard extends StatelessWidget {
  final FichaListEntity ficha;
  final VoidCallback onTap;
  const _FichaCard({required this.ficha, required this.onTap});

  Color get _etapaColor =>
      ficha.esProductiva ? AppTheme.accent : AppTheme.primary;

  Color get _estadoColor {
    switch (ficha.estado) {
      case 'ACTIVA':   return AppTheme.primary;
      case 'INACTIVA': return Colors.orange;
      case 'CERRADA':  return Colors.red.shade400;
      default:         return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Badge(label: ficha.codigoFicha, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  if (ficha.cadenaFormacion)
                    _Badge(label: 'Cadena', color: AppTheme.accent, icon: Icons.link),
                  const Spacer(),
                  _Badge(label: ficha.estado, color: _estadoColor),
                ],
              ),
              const SizedBox(height: 10),
              Text(ficha.programaNombre,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  )),
              const SizedBox(height: 2),
              Text('v${ficha.versionNumero} · ${ficha.jornadaDisplay}',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withOpacity(0.7))),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Badge(label: ficha.etapaDisplay, color: _etapaColor),
                  const SizedBox(width: 6),
                  _Badge(label: 'T${ficha.trimestre}', color: AppTheme.textSecondary),
                  const Spacer(),
                  Icon(Icons.people_outline,
                      size: 14,
                      color: AppTheme.textSecondary.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text(
                    '${ficha.numeroEstudiantesReal}/${ficha.numeroEstudiantesEstimado}',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary.withOpacity(0.7)),
                  ),
                ],
              ),
              if (ficha.jefeGrupoNombre != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 13,
                        color: AppTheme.textSecondary.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text(ficha.jefeGrupoNombre!,
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary.withOpacity(0.5))),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const _Badge({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _FiltroChips extends StatelessWidget {
  final String label;
  final Map<String, String> opciones;
  final String? seleccionado;
  final ValueChanged<String?> onSelected;
  const _FiltroChips({
    required this.label,
    required this.opciones,
    required this.seleccionado,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: opciones.entries.map((e) {
            final sel = seleccionado == e.key;
            return GestureDetector(
              onTap: () => onSelected(sel ? null : e.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: sel
                      ? AppTheme.primary.withOpacity(0.2)
                      : AppTheme.surfaceLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: sel
                          ? AppTheme.primary
                          : AppTheme.border.withOpacity(0.5)),
                ),
                child: Text(e.value,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel
                            ? AppTheme.primary
                            : AppTheme.textSecondary)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TriSwitch extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?> onChanged;
  const _TriSwitch({required this.value, required this.onChanged});

  Widget _chip(String label, bool? val) {
    final sel = value == val;
    return GestureDetector(
      onTap: () => onChanged(val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: sel ? AppTheme.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: sel ? AppTheme.primary : AppTheme.border.withOpacity(0.5)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: sel ? AppTheme.primary : AppTheme.textSecondary)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _chip('Sí', true),
        const SizedBox(width: 6),
        _chip('No', false),
        const SizedBox(width: 6),
        _chip('Todos', null),
      ],
    );
  }
}
