// lib/features/planificacion/presentation/widgets/planificacion_widgets.dart

import 'package:flutter/material.dart';

import '../../domain/entities/plan_trimestral_entity.dart';

// ── EstadoChip ────────────────────────────────────────────────────────────────

/// Función pública para obtener (color, icon) de un EstadoPlan.
/// Usada tanto por [EstadoChip] como por [CambiarEstadoView].
(Color, IconData) estadoChipConfig(EstadoPlan e) {
  switch (e) {
    case EstadoPlan.borrador:
      return (Colors.grey, Icons.edit_outlined);
    case EstadoPlan.enRevision:
      return (Colors.amber, Icons.hourglass_top_rounded);
    case EstadoPlan.aprobado:
      return (const Color(0xFF35F58A), Icons.check_circle_outline);
    case EstadoPlan.enEjecucion:
      return (const Color(0xFF28D7FF), Icons.play_circle_outline);
    case EstadoPlan.cerrado:
      return (Colors.blueGrey, Icons.lock_outline);
    case EstadoPlan.rechazado:
      return (Colors.redAccent, Icons.cancel_outlined);
  }
}

class EstadoChip extends StatelessWidget {
  final EstadoPlan estado;
  final bool       small;

  const EstadoChip({super.key, required this.estado, this.small = false});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = estadoChipConfig(estado);
    final fontSize = small ? 10.0 : 11.0;
    final padding  = small
        ? const EdgeInsets.symmetric(horizontal: 8,  vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 5);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color:        color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: small ? 10 : 12, color: color),
          const SizedBox(width: 4),
          Text(
            estado.label,
            style: TextStyle(
              color:       color,
              fontSize:    fontSize,
              fontWeight:  FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── ProgresoPlan ──────────────────────────────────────────────────────────────

class ProgresoPlan extends StatelessWidget {
  final double porcentaje;
  final double ejecutadas;
  final double planificadas;
  final bool   compact;

  const ProgresoPlan({
    super.key,
    required this.porcentaje,
    required this.ejecutadas,
    required this.planificadas,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final pct     = (porcentaje / 100).clamp(0.0, 1.0);
    final color   = _progressColor(porcentaje);
    final ejStr   = ejecutadas % 1 == 0
        ? ejecutadas.toInt().toString()
        : ejecutadas.toStringAsFixed(1);
    final planStr = planificadas % 1 == 0
        ? planificadas.toInt().toString()
        : planificadas.toStringAsFixed(1);

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$ejStr / ${planStr}h',
                style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6)),
              ),
              Text(
                '${porcentaje.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value:          pct,
              minHeight:      5,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor:     AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Avance del plan',
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
            ),
            Text(
              '${porcentaje.toStringAsFixed(1)}%',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value:          pct,
            minHeight:      8,
            backgroundColor: Colors.white.withOpacity(0.08),
            valueColor:     AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$ejStr h ejecutadas de $planStr h planificadas',
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
        ),
      ],
    );
  }

  Color _progressColor(double pct) {
    if (pct >= 90) return const Color(0xFF35F58A);
    if (pct >= 50) return const Color(0xFF28D7FF);
    if (pct >= 20) return Colors.amber;
    return Colors.redAccent;
  }
}

// ── PlanCard ──────────────────────────────────────────────────────────────────

class PlanCard extends StatelessWidget {
  final PlanTrimestral plan;
  final VoidCallback   onTap;

  const PlanCard({super.key, required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color:        const Color(0xFF0C1E29),
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(
            color: const Color(0xFF1D4E42).withOpacity(0.7),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ficha ${plan.fichaCodigo}',
                          style: const TextStyle(
                            color:      Color(0xFFEAFBF4),
                            fontWeight: FontWeight.w700,
                            fontSize:   15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          plan.programaNombre,
                          style: TextStyle(
                            color:    Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  EstadoChip(estado: plan.estado, small: true),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoPill(
                    icon:  Icons.calendar_today_outlined,
                    label: 'T${plan.trimestre}',
                  ),
                  const SizedBox(width: 8),
                  _InfoPill(
                    icon:  Icons.date_range_outlined,
                    label: _rangoFechas(plan.fechaInicio, plan.fechaFin),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ProgresoPlan(
                porcentaje:   plan.porcentajeAvance,
                ejecutadas:   plan.totalHorasEjecutadas,
                planificadas: plan.totalHorasPlanificadas,
                compact:      true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _rangoFechas(DateTime ini, DateTime fin) {
    String f(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
    return '${f(ini)} – ${f(fin)}';
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withOpacity(0.4)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}

// ── ItemPlanCard ──────────────────────────────────────────────────────────────

class ItemPlanCard extends StatelessWidget {
  final ItemPlan     item;
  final bool         canEdit;
  final VoidCallback? onEdit;

  const ItemPlanCard({
    super.key,
    required this.item,
    this.canEdit = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        const Color(0xFF112734),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(
          color: const Color(0xFF1D4E42).withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TipoBadge(tipo: item.competenciaTipo),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.competenciaCodigo,
                  style: const TextStyle(
                    color:      Color(0xFF35F58A),
                    fontWeight: FontWeight.w700,
                    fontSize:   13,
                  ),
                ),
              ),
              if (item.completado)
                const Icon(Icons.check_circle,
                    color: Color(0xFF35F58A), size: 16),
              if (canEdit && !item.completado && onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Icon(
                    Icons.edit_outlined,
                    size:  16,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.competenciaNombre,
            style: TextStyle(
              color:    Colors.white.withOpacity(0.75),
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_outline,
                  size: 12, color: Colors.white.withOpacity(0.35)),
              const SizedBox(width: 4),
              Text(
                item.docenteNombre ?? 'Sin docente asignado',
                style: TextStyle(
                  fontSize:   11,
                  color:      item.docenteNombre != null
                      ? Colors.white.withOpacity(0.55)
                      : Colors.redAccent.withOpacity(0.8),
                  fontStyle: item.docenteNombre != null
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProgresoPlan(
            porcentaje:   item.porcentajeAvance,
            ejecutadas:   item.horasEjecutadas,
            planificadas: item.horasAsignadas.toDouble(),
            compact:      true,
          ),
        ],
      ),
    );
  }
}

class _TipoBadge extends StatelessWidget {
  final String tipo;
  const _TipoBadge({required this.tipo});

  @override
  Widget build(BuildContext context) {
    final isPrincipal = tipo.toUpperCase() == 'PRINCIPAL';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isPrincipal
            ? const Color(0xFF35F58A).withOpacity(0.1)
            : const Color(0xFF28D7FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isPrincipal
              ? const Color(0xFF35F58A).withOpacity(0.4)
              : const Color(0xFF28D7FF).withOpacity(0.4),
        ),
      ),
      child: Text(
        isPrincipal ? 'PRINCIPAL' : 'TRANSVERSAL',
        style: TextStyle(
          fontSize:     9,
          fontWeight:   FontWeight.w700,
          color:        isPrincipal
              ? const Color(0xFF35F58A)
              : const Color(0xFF28D7FF),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── SkeletonBox / PlanCardSkeleton ────────────────────────────────────────────

class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width  = double.infinity,
    required this.height,
    this.radius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.04, end: 0.12).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder:   (_, __) => Container(
        width:  widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color:        Colors.white.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

class PlanCardSkeleton extends StatelessWidget {
  const PlanCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        const Color(0xFF0C1E29),
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(
            color: const Color(0xFF1D4E42).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(child: SkeletonBox(height: 14, width: 120)),
            const SizedBox(width: 12),
            SkeletonBox(height: 22, width: 80, radius: 20),
          ]),
          const SizedBox(height: 10),
          const SkeletonBox(height: 10, width: 160),
          const SizedBox(height: 14),
          Row(children: [
            SkeletonBox(height: 24, width: 48,  radius: 8),
            const SizedBox(width: 8),
            SkeletonBox(height: 24, width: 100, radius: 8),
          ]),
          const SizedBox(height: 14),
          const SkeletonBox(height: 5, radius: 4),
        ],
      ),
    );
  }
}

// ── ErrorBanner ───────────────────────────────────────────────────────────────

class ErrorBanner extends StatelessWidget {
  final String       message;
  final VoidCallback? onRetry;

  const ErrorBanner({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar',
                  style: TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}
