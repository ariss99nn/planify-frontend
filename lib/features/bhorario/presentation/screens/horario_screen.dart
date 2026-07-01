// lib/features/bhorario/presentation/screens/horario_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_roles.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/bloque_horario_model.dart';
import '../providers/horario_provider.dart';
import '../widgets/bloque_card.dart';
import '../widgets/bloque_detail_sheet.dart';
import '../widgets/bloque_form_sheet.dart';

class HorarioScreen extends StatefulWidget {
  final String userRole;
  const HorarioScreen({
    super.key,
    this.userRole = AppRoles.estudiante,
  });

  @override
  State<HorarioScreen> createState() => _HorarioScreenState();
}

class _HorarioScreenState extends State<HorarioScreen>
    with SingleTickerProviderStateMixin {
  late final HorarioProvider _provider;
  late final TabController   _tabController;

  // FIX B26: flag para evitar loop de listeners
  bool _syncingTab = false;

  static const _dias = [
    ('LUNES',     'Lun'),
    ('MARTES',    'Mar'),
    ('MIERCOLES', 'Mié'),
    ('JUEVES',    'Jue'),
    ('VIERNES',   'Vie'),
    ('SABADO',    'Sáb'),
  ];

  static const _jornadas = [
    (null,     'Todas'),
    ('MANANA', 'Mañana'),
    ('TARDE',  'Tarde'),
    ('NOCHE',  'Noche'),
  ];

  bool get _isManager => AppRoles.managers.contains(widget.userRole);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _provider      = HorarioProvider();
    _tabController = TabController(length: _dias.length, vsync: this);

    // Tab → Provider (usuario toca una tab)
    _tabController.addListener(_onTabChanged);

    // Provider → Tab (FIX B27: cuando el provider auto-selecciona un día,
    // sincroniza el TabController sin crear un loop)
    _provider.addListener(_onProviderChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadHorarioSemanal();
    });
  }

  void _onTabChanged() {
    if (_syncingTab) return;                              // evita loop
    if (_tabController.indexIsChanging) return;           // ignorar frames intermedios
    _provider.seleccionarDia(_dias[_tabController.index].$1);
  }

  void _onProviderChanged() {
    if (!mounted) return;
    final targetIdx = _dias.indexWhere(
      (d) => d.$1 == _provider.diaSeleccionado,
    );
    if (targetIdx < 0) return;
    if (_tabController.index == targetIdx) return;        // ya está correcto
    if (_tabController.indexIsChanging) return;

    // FIX B26: actualiza el tab desde el provider sin disparar _onTabChanged
    _syncingTab = true;
    _tabController.animateTo(targetIdx);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncingTab = false;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _provider.removeListener(_onProviderChanged);
    _provider.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ── Acciones ───────────────────────────────────────────────────────────────

  void _abrirDetalle(BloqueHorarioModel bloque) {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => BloqueDetailSheet(
        bloque:    bloque,
        isManager: _isManager,
        onEdit: () {
          Navigator.pop(context);
          _abrirFormulario(existing: bloque);
        },
        onDelete: () async {
          Navigator.pop(context);
          final ok = await _provider.deleteBloque(bloque.id);
          if (mounted && !ok) _mostrarError(_provider.error);
        },
      ),
    );
  }

  void _abrirFormulario({BloqueHorarioModel? existing}) {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => BloqueFormSheet(
        existing: existing,
        onSave: (data) async {
          Navigator.pop(context);
          final result = existing != null
              ? await _provider.updateBloque(existing.id, data)
              : await _provider.createBloque(data);
          if (!mounted) return;
          result != null
              ? _mostrarExito(
                  existing != null ? 'Bloque actualizado' : 'Bloque creado')
              : _mostrarError(_provider.error);
        },
      ),
    );
  }

  void _mostrarExito(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text(msg),
          backgroundColor: AppTheme.primaryDark,
          behavior:        SnackBarBehavior.floating,
        ),
      );

  void _mostrarError(String? msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text(msg ?? 'Ocurrió un error'),
          backgroundColor: Colors.redAccent,
          behavior:        SnackBarBehavior.floating,
        ),
      );

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) => Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              _Header(
                totalBloques: _provider.horarioSemanal?.totalBloques,
                isLoading:    _provider.isLoading,
                onRefresh:    _provider.loadHorarioSemanal,
              ),
              if (_isManager)
                _JornadaFilterBar(
                  jornadas:      _jornadas,
                  seleccionada:  _provider.filtroJornada,
                  onSeleccionar: _provider.setFiltroJornada,
                ),
              _DayTabBar(
                dias:          _dias,
                tabController: _tabController,
                conteosPorDia: {
                  for (final d in _dias)
                    d.$1: _provider.horarioSemanal?.dias[d.$1]?.bloques.length ?? 0,
                },
              ),
              Expanded(child: _buildCuerpo()),
            ],
          ),
        ),
        floatingActionButton: _isManager
            ? FloatingActionButton.extended(
                heroTag: 'fab_horario',
                onPressed:       () => _abrirFormulario(),
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
                icon:            const Icon(Icons.add_rounded),
                label: const Text(
                  'Nuevo bloque',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildCuerpo() {
    if (_provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }
    if (_provider.hasError) {
      return _ErrorView(
        mensaje: _provider.error ?? 'No se pudo cargar el horario',
        onRetry: _provider.loadHorarioSemanal,
      );
    }
    return TabBarView(
      controller: _tabController,
      children: _dias.map((d) {
        final bloques = _provider.horarioSemanal?.dias[d.$1]?.bloques ?? [];
        if (bloques.isEmpty) return _EmptyDia(diaClave: d.$1);
        return ListView.separated(
          padding:          const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount:        bloques.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder:      (_, i) => BloqueCard(
            bloque: bloques[i],
            onTap:  () => _abrirDetalle(bloques[i]),
          ),
        );
      }).toList(),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int?         totalBloques;
  final bool         isLoading;
  final VoidCallback onRefresh;
  const _Header({
    required this.totalBloques,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
      decoration: const BoxDecoration(
        color:  AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color:        AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppTheme.primary, size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Horario Semanal',
                  style: TextStyle(
                    color: AppTheme.textPrimary, fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (totalBloques != null)
                  Text(
                    '$totalBloques bloque${totalBloques == 1 ? '' : 's'} '
                    'programado${totalBloques == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            tooltip:   'Actualizar',
            icon: isLoading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.primary,
                    ),
                  )
                : const Icon(
                    Icons.refresh_rounded, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _JornadaFilterBar extends StatelessWidget {
  final List<(String?, String)> jornadas;
  final String?                 seleccionada;
  final void Function(String?)  onSeleccionar;
  const _JornadaFilterBar({
    required this.jornadas,
    required this.seleccionada,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height:  48,
      color:   AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: jornadas.map((j) {
          final sel = seleccionada == j.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
            child: FilterChip(
              label:         Text(j.$2),
              selected:      sel,
              onSelected:    (_) => onSeleccionar(j.$1),
              selectedColor: AppTheme.primary,
              checkmarkColor: Colors.black,
              labelStyle:    TextStyle(
                color:      sel ? Colors.black : AppTheme.textSecondary,
                fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                fontSize:   13,
              ),
              backgroundColor: AppTheme.surfaceLight,
              side: BorderSide(
                  color: sel ? AppTheme.primary : AppTheme.border),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DayTabBar extends StatelessWidget {
  final List<(String, String)> dias;
  final TabController          tabController;
  final Map<String, int>       conteosPorDia;
  const _DayTabBar({
    required this.dias,
    required this.tabController,
    required this.conteosPorDia,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      child: TabBar(
        controller:           tabController,
        isScrollable:         true,
        tabAlignment:         TabAlignment.start,
        dividerColor:         AppTheme.border,
        labelColor:           AppTheme.primary,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        indicator: BoxDecoration(
          color:        AppTheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border:       Border.all(color: AppTheme.primary),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tabs: dias.map((d) {
          final count = conteosPorDia[d.$1] ?? 0;
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(d.$2),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 18, height: 18,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary, shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.black, fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyDia extends StatelessWidget {
  final String diaClave;
  const _EmptyDia({required this.diaClave});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color:  AppTheme.surfaceLight,
                shape:  BoxShape.circle,
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(
                Icons.event_available_rounded,
                size: 32, color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sin clases este día',
              style: TextStyle(
                color: AppTheme.textPrimary, fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No hay bloques horarios programados.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String       mensaje;
  final VoidCallback onRetry;
  const _ErrorView({required this.mensaje, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon:      const Icon(Icons.refresh_rounded),
              label:     const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}