// lib/features/planificacion/presentation/widgets/views/plan_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_roles.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../domain/entities/plan_trimestral_entity.dart';
import '../../providers/planificacion_provider.dart';
import '../planificacion_widgets.dart';
import 'plan_auto_generar_view.dart';
import 'plan_detail_view.dart';
import 'plan_form_view.dart';

class PlanListView extends StatefulWidget {
  const PlanListView({super.key});

  @override
  State<PlanListView> createState() => _PlanListViewState();
}

class _PlanListViewState extends State<PlanListView> {
  EstadoPlan? _estadoFiltro;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _cargar({bool reset = true}) {
    context.read<PlanificacionProvider>().cargarPlanes(
          filtros: PlanTrimestralFiltros(estado: _estadoFiltro),
          reset:   reset,
        );
  }

  Future<void> _abrirDetalle(PlanTrimestral plan) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlanDetailView(planId: plan.id),
      ),
    );
    _cargar();
  }

  Future<void> _abrirFormulario() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlanFormView()),
    );
    _cargar();
  }

  Future<void> _abrirAutoGenerar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlanAutoGenerarView()),
    );
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<AuthProvider>();
    final rol          = userProvider.user?.rol ?? '';
    final isManager    = AppRoles.managers.contains(rol);

    return Scaffold(
      backgroundColor: const Color(0xFF06141D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06141D),
        title: const Text(
          'Planes Trimestrales',
          style: TextStyle(
            color:      Color(0xFFEAFBF4),
            fontWeight: FontWeight.w700,
            fontSize:   18,
          ),
        ),
        centerTitle: false,
        elevation:   0,
        actions: [
          IconButton(
            icon:    const Icon(Icons.refresh_rounded, color: Color(0xFF35F58A)),
            onPressed: _cargar,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: isManager
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'fab_manual',
                  onPressed:       _abrirFormulario,
                  backgroundColor: const Color(0xFF0C1E29),
                  foregroundColor: const Color(0xFFEAFBF4),
                  icon:            const Icon(Icons.edit_note_rounded, size: 20),
                  label: const Text(
                    'Manual',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'fab_auto',
                  onPressed:       _abrirAutoGenerar,
                  backgroundColor: const Color(0xFF35F58A),
                  foregroundColor: Colors.black,
                  icon:            const Icon(Icons.bolt_rounded),
                  label: const Text(
                    'Generar automáticamente',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          _FiltroEstado(
            seleccionado: _estadoFiltro,
            onChanged: (e) {
              setState(() => _estadoFiltro = e);
              _cargar();
            },
          ),
          Expanded(
            child: Consumer<PlanificacionProvider>(
              builder: (context, provider, _) {
                if (provider.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: ErrorBanner(
                        message: provider.error!,
                        onRetry: _cargar,
                      ),
                    ),
                  );
                }

                if (provider.isLoadingList && provider.planes.isEmpty) {
                  return ListView.builder(
                    padding:     const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount:   5,
                    itemBuilder: (_, __) => const PlanCardSkeleton(),
                  );
                }

                if (!provider.isLoadingList && provider.planes.isEmpty) {
                  return _EmptyState(
                    isManager: isManager,
                    onCreate:  _abrirFormulario,
                    onAutoGenerate: _abrirAutoGenerar,
                  );
                }

                return RefreshIndicator(
                  color:     const Color(0xFF35F58A),
                  onRefresh: () async => _cargar(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding:    const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount:  provider.planes.length +
                        (provider.hasMorePlanes ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.planes.length) {
                        return _LoadMoreButton(
                          onTap: () => _cargar(reset: false),
                        );
                      }
                      final plan = provider.planes[index];
                      return PlanCard(
                        plan:  plan,
                        onTap: () => _abrirDetalle(plan),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filtro de estado ──────────────────────────────────────────────────────────

class _FiltroEstado extends StatelessWidget {
  final EstadoPlan?                seleccionado;
  final ValueChanged<EstadoPlan?>  onChanged;

  const _FiltroEstado({
    required this.seleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final opciones = [null, ...EstadoPlan.values];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection:  Axis.horizontal,
        padding:          const EdgeInsets.symmetric(horizontal: 16),
        itemCount:        opciones.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final estado   = opciones[i];
          final selected = estado == seleccionado;
          final label    = estado?.label ?? 'Todos';

          return GestureDetector(
            onTap: () => onChanged(estado),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF35F58A).withOpacity(0.15)
                    : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF35F58A)
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF35F58A)
                      : Colors.white.withOpacity(0.5),
                  fontSize:   12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Estado vacío ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool         isManager;
  final VoidCallback onCreate;
  final VoidCallback onAutoGenerate;

  const _EmptyState({
    required this.isManager,
    required this.onCreate,
    required this.onAutoGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size:  64,
              color: Colors.white.withOpacity(0.15),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin planes trimestrales',
              style: TextStyle(
                color:      Colors.white.withOpacity(0.5),
                fontSize:   16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isManager
                  ? 'Genera el primer plan automáticamente para comenzar.'
                  : 'Aún no hay planes asignados.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:    Colors.white.withOpacity(0.3),
                fontSize: 13,
              ),
            ),
            if (isManager) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAutoGenerate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF35F58A),
                  foregroundColor: Colors.black,
                ),
                icon:  const Icon(Icons.bolt_rounded, size: 18),
                label: const Text('Generar automáticamente'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onCreate,
                icon:      const Icon(Icons.add, size: 18),
                label:     const Text('Crear manualmente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LoadMoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: OutlinedButton(
          onPressed: onTap,
          child:     const Text('Cargar más'),
        ),
      ),
    );
  }
}
