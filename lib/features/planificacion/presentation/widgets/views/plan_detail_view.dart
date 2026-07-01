// lib/features/planificacion/presentation/widgets/views/plan_detail_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_roles.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../domain/entities/plan_trimestral_entity.dart';
import '../../providers/planificacion_provider.dart';
import '../planificacion_widgets.dart';
import 'cambiar_estado_view.dart';
import 'item_form_view.dart';
import 'plan_form_view.dart';

class PlanDetailView extends StatefulWidget {
  final int planId;
  const PlanDetailView({super.key, required this.planId});

  @override
  State<PlanDetailView> createState() => _PlanDetailViewState();
}

class _PlanDetailViewState extends State<PlanDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanificacionProvider>().cargarDetallePlan(widget.planId);
    });
  }

  Future<void> _abrirCambiarEstado(PlanTrimestralDetalle plan) async {
    await showModalBottomSheet(
      context:             context,
      isScrollControlled:  true,
      backgroundColor:     Colors.transparent,
      builder: (_) => CambiarEstadoView(plan: plan),
    );
  }

  Future<void> _abrirEditarFechas(PlanTrimestralDetalle plan) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlanFormView(planToEdit: plan),
      ),
    );
    if (mounted) {
      context.read<PlanificacionProvider>().cargarDetallePlan(widget.planId);
    }
  }

  Future<void> _abrirAgregarItem(PlanTrimestralDetalle plan) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemFormView(planId: plan.id),
      ),
    );
    if (mounted) {
      context.read<PlanificacionProvider>().cargarDetallePlan(widget.planId);
    }
  }

  Future<void> _abrirEditarItem(
    ItemPlan           item,
    PlanTrimestralDetalle plan,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemFormView(planId: plan.id, itemToEdit: item),
      ),
    );
    if (mounted) {
      context.read<PlanificacionProvider>().cargarDetallePlan(widget.planId);
    }
  }

  Future<void> _generarHorario() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0C1E29),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Generar horarios',
            style: TextStyle(color: Color(0xFFEAFBF4))),
        content: const Text(
          'Se generarán bloques horarios automáticamente para todos los ítems '
          'del plan. ¿Confirmas?',
          style: TextStyle(color: Color(0xFF9DC5B5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Generar'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final resultado =
        await context.read<PlanificacionProvider>().generarHorario();
    if (!mounted) return;
    if (resultado != null) _mostrarResultadoHorario(resultado);
  }

  void _mostrarResultadoHorario(ResultadoGenerarHorario r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0C1E29),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              r.completado ? Icons.check_circle : Icons.warning_amber_rounded,
              color: r.completado ? const Color(0xFF35F58A) : Colors.amber,
            ),
            const SizedBox(width: 8),
            Text(
              r.completado ? 'Horarios generados' : 'Generado con conflictos',
              style: const TextStyle(color: Color(0xFFEAFBF4), fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize:        MainAxisSize.min,
          crossAxisAlignment:  CrossAxisAlignment.start,
          children: [
            Text(
              '${r.bloquesCreados} bloques creados.',
              style: const TextStyle(color: Color(0xFF9DC5B5)),
            ),
            if (r.conflictos.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '${r.conflictos.length} conflicto(s):',
                style: const TextStyle(
                    color: Colors.amber, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              ...r.conflictos.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${c.item}: ${c.error}',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rol       = context.read<AuthProvider>().user?.rol ?? '';
    final isManager = AppRoles.managers.contains(rol);

    return Scaffold(
      backgroundColor: const Color(0xFF06141D),
      body: Consumer<PlanificacionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingDetail) {
            return const _DetalleSkeleton();
          }

          if (provider.error != null && provider.selectedPlan == null) {
            return Scaffold(
              appBar: AppBar(backgroundColor: const Color(0xFF06141D)),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ErrorBanner(
                    message: provider.error!,
                    onRetry: () =>
                        provider.cargarDetallePlan(widget.planId),
                  ),
                ),
              ),
            );
          }

          final plan = provider.selectedPlan;
          if (plan == null) return const SizedBox.shrink();

          final puedeEditar          = isManager && plan.estado.esEditable;
          final puedeCambiarEstado   = isManager;
          final puedeAgregarItem     = isManager && plan.estado.esEditable;
          final puedeGenerarHorario  =
              isManager && plan.estado == EstadoPlan.aprobado;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor:  const Color(0xFF06141D),
                pinned:           true,
                expandedHeight:   160,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  title: Column(
                    mainAxisAlignment:   MainAxisAlignment.end,
                    crossAxisAlignment:  CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ficha ${plan.fichaCodigo}',
                        style: const TextStyle(
                          color:      Color(0xFFEAFBF4),
                          fontWeight: FontWeight.w800,
                          fontSize:   16,
                        ),
                      ),
                      Text(
                        'Trimestre ${plan.trimestre}',
                        style: TextStyle(
                          color:    Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  background: _AppBarBackground(plan: plan),
                ),
                actions: [
                  if (puedeEditar)
                    IconButton(
                      icon: const Icon(Icons.edit_calendar_outlined,
                          color: Color(0xFF35F58A)),
                      onPressed: () => _abrirEditarFechas(plan),
                      tooltip:   'Editar fechas',
                    ),
                  if (puedeCambiarEstado)
                    IconButton(
                      icon: const Icon(Icons.swap_horiz_rounded,
                          color: Color(0xFF28D7FF)),
                      onPressed: () => _abrirCambiarEstado(plan),
                      tooltip:   'Cambiar estado',
                    ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (provider.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ErrorBanner(message: provider.error!),
                        ),
                      _SeccionInfo(plan: plan),
                      const SizedBox(height: 16),
                      _SeccionProgreso(plan: plan),
                      const SizedBox(height: 20),
                      if (puedeGenerarHorario || puedeCambiarEstado)
                        _SeccionAcciones(
                          plan:                plan,
                          isSubmitting:        provider.isSubmitting,
                          puedeGenerarHorario: puedeGenerarHorario,
                          onGenerarHorario:    _generarHorario,
                          onCambiarEstado:     () => _abrirCambiarEstado(plan),
                        ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Competencias del plan',
                            style: TextStyle(
                              color:      Color(0xFFEAFBF4),
                              fontWeight: FontWeight.w700,
                              fontSize:   15,
                            ),
                          ),
                          if (puedeAgregarItem)
                            TextButton.icon(
                              onPressed: () => _abrirAgregarItem(plan),
                              icon:  const Icon(Icons.add, size: 16),
                              label: const Text('Agregar'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF35F58A),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              if (plan.items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Sin competencias registradas.',
                        style: TextStyle(
                          color:    Colors.white.withOpacity(0.3),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => ItemPlanCard(
                        item:    plan.items[i],
                        canEdit: puedeAgregarItem,
                        onEdit:  () => _abrirEditarItem(plan.items[i], plan),
                      ),
                      childCount: plan.items.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _AppBarBackground extends StatelessWidget {
  final PlanTrimestralDetalle plan;
  const _AppBarBackground({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
          colors: [Color(0xFF0C1E29), Color(0xFF06141D)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 56, 16, 60),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                plan.programaNombre,
                style: TextStyle(
                  color:    Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            EstadoChip(estado: plan.estado),
          ],
        ),
      ),
    );
  }
}

class _SeccionInfo extends StatelessWidget {
  final PlanTrimestralDetalle plan;
  const _SeccionInfo({required this.plan});

  @override
  Widget build(BuildContext context) {
    String fmtDate(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        const Color(0xFF0C1E29),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(
            color: const Color(0xFF1D4E42).withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: 'Período',
            value: '${fmtDate(plan.fechaInicio)} → ${fmtDate(plan.fechaFin)}',
          ),
          if (plan.aprobadoPorNombre != null) ...[
            const Divider(color: Color(0xFF1D4E42), height: 16),
            _InfoRow(label: 'Aprobado por', value: plan.aprobadoPorNombre!),
          ],
          if (plan.estado == EstadoPlan.rechazado &&
              plan.motivoRechazo.isNotEmpty) ...[
            const Divider(color: Color(0xFF1D4E42), height: 16),
            _InfoRow(
              label:      'Motivo rechazo',
              value:      plan.motivoRechazo,
              valueColor: Colors.redAccent,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String  label;
  final String  value;
  final Color?  valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color:      valueColor ?? const Color(0xFFEAFBF4),
              fontSize:   12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _SeccionProgreso extends StatelessWidget {
  final PlanTrimestralDetalle plan;
  const _SeccionProgreso({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        const Color(0xFF0C1E29),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(
            color: const Color(0xFF1D4E42).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso general',
                style: TextStyle(
                  color:      Color(0xFFEAFBF4),
                  fontWeight: FontWeight.w600,
                  fontSize:   13,
                ),
              ),
              Text(
                '${plan.items.length} competencia(s)',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgresoPlan(
            porcentaje:   plan.porcentajeAvance,
            ejecutadas:   plan.totalHorasEjecutadas,
            planificadas: plan.totalHorasPlanificadas,
          ),
        ],
      ),
    );
  }
}

class _SeccionAcciones extends StatelessWidget {
  final PlanTrimestralDetalle plan;
  final bool         isSubmitting;
  final bool         puedeGenerarHorario;
  final VoidCallback onGenerarHorario;
  final VoidCallback onCambiarEstado;

  const _SeccionAcciones({
    required this.plan,
    required this.isSubmitting,
    required this.puedeGenerarHorario,
    required this.onGenerarHorario,
    required this.onCambiarEstado,
  });

  @override
  Widget build(BuildContext context) {
    final transiciones = plan.estado.transicionesValidas;

    return Column(
      children: [
        if (puedeGenerarHorario)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSubmitting ? null : onGenerarHorario,
              icon: isSubmitting
                  ? const SizedBox(
                      width:  16,
                      height: 16,
                      child:  CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: const Text('Generar horarios automáticamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF28D7FF),
                foregroundColor: Colors.black,
              ),
            ),
          ),
        if (transiciones.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isSubmitting ? null : onCambiarEstado,
              icon:  const Icon(Icons.swap_horiz_rounded, size: 18),
              label: const Text('Cambiar estado del plan'),
            ),
          ),
        ],
      ],
    );
  }
}

class _DetalleSkeleton extends StatelessWidget {
  const _DetalleSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06141D),
      appBar: AppBar(backgroundColor: const Color(0xFF06141D)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SkeletonBox(height: 20, width: 200),
            SizedBox(height: 8),
            SkeletonBox(height: 12, width: 140),
            SizedBox(height: 20),
            SkeletonBox(height: 100, radius: 14),
            SizedBox(height: 16),
            SkeletonBox(height: 80, radius: 14),
            SizedBox(height: 20),
            SkeletonBox(height: 14, width: 180),
            SizedBox(height: 12),
            SkeletonBox(height: 80, radius: 12),
            SizedBox(height: 10),
            SkeletonBox(height: 80, radius: 12),
          ],
        ),
      ),
    );
  }
}
