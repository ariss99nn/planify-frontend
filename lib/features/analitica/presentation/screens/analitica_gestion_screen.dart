import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/datasources/analitica_remote_datasource.dart';
import '../../data/repositories_impl/analitica_repository_impl.dart';
import '../../domain/entities/analitica_entities.dart';
import '../../domain/usecases/analitica_usecases.dart';
import '../providers/analitica_provider.dart';

class AnaliticaGestionScreen extends StatelessWidget {
  const AnaliticaGestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final ds         = AnaliticaRemoteDataSourceImpl();
        final repo       = AnaliticaRepositoryImpl(ds);
        final dashboard  = GetDashboardUseCase(repo);
        final snapshots  = GetSnapshotsUseCase(repo);
        return AnaliticaProvider(
          getDashboard: dashboard,
          getSnapshots: snapshots,
        );
      },
      child: const _AnaliticaGestionView(),
    );
  }
}

class _AnaliticaGestionView extends StatefulWidget {
  const _AnaliticaGestionView();

  @override
  State<_AnaliticaGestionView> createState() => _AnaliticaGestionViewState();
}

class _AnaliticaGestionViewState extends State<_AnaliticaGestionView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ANALÍTICA',
          style: TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 2.5,
          labelPadding: const EdgeInsets.only(bottom: 6),
          tabs: const [
            Tab(text: 'Resumen',   icon: Icon(Icons.analytics_outlined, size: 20)),
            Tab(text: 'Historial', icon: Icon(Icons.history_rounded,    size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _DashboardView(),
          _SnapshotListView(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 — Resumen
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnaliticaProvider>().cargarDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = context.watch<AnaliticaProvider>();

    if (provider.dashboardLoading) {
      return const CyberLoadingView();
    }
    if (provider.dashboardError != null) {
      return CyberErrorView(
        message: provider.dashboardError!,
        onRetry: () => context.read<AnaliticaProvider>().cargarDashboard(),
      );
    }
    if (provider.sinSnapshot) {
      return const CyberEmptyView(
        icon:     Icons.analytics_outlined,
        title:    'Sin datos',
        subtitle: 'No hay snapshots generados aún.\n'
                  'Ejecuta la tarea Celery para generar el primero.',
      );
    }
    if (provider.dashboard == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: () => context.read<AnaliticaProvider>().cargarDashboard(),
      color: AppTheme.primary,
      child: _DashboardContent(data: provider.dashboard!),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contenido del dashboard
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  final DashboardEntity data;
  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MetricSection(
          title:   'Fichas',
          icon:    Icons.folder_copy_rounded,
          columns: 3,
          metrics: [
            _Metric('Activas',    data.fichasActivas,    AppTheme.primary),
            _Metric('Lectiva',    data.fichasLectiva,    AppTheme.accent),
            _Metric('Productiva', data.fichasProductiva, AppTheme.textSecondary),
          ],
        ),
        const SizedBox(height: 12),
        _MetricSection(
          title:   'Estudiantes',
          icon:    Icons.people_rounded,
          columns: 2,
          metrics: [
            _Metric('Activos',     data.estudiantesActivos, AppTheme.primary),
            _Metric('Deserciones', data.desercionesMes,
                data.desercionesMes > 0 ? Colors.orangeAccent : AppTheme.textSecondary,
                sub: 'este mes'),
            _Metric('Graduados',   data.graduadosMes,   AppTheme.accent, sub: 'este mes'),
            _Metric('Reasignados', data.reasignacionesMes, AppTheme.textSecondary, sub: 'este mes'),
          ],
        ),
        const SizedBox(height: 12),
        _MetricSection(
          title:   'Docentes',
          icon:    Icons.school_rounded,
          columns: 2,
          metrics: [
            _Metric('Activos', data.docentesActivos, AppTheme.primary),
            _Metric('Sobrecargados', data.docentesSobrecargados,
                data.docentesSobrecargados > 0 ? Colors.orangeAccent : AppTheme.textSecondary),
          ],
        ),
        const SizedBox(height: 12),
        _MetricSection(
          title:   'Aulas',
          icon:    Icons.meeting_room_rounded,
          columns: 3,
          metrics: [
            _Metric('Activas', data.aulasActivas, AppTheme.primary),
            _Metric('Mantenimiento', data.aulasMantenimiento,
                data.aulasMantenimiento > 0 ? Colors.orangeAccent : AppTheme.textSecondary),
            _Metric('Inactivas', data.aulasInactivas, AppTheme.textSecondary),
          ],
        ),
        const SizedBox(height: 12),
        _MetricSection(
          title:   'Planes Trimestrales',
          icon:    Icons.assignment_rounded,
          columns: 2,
          metrics: [
            _Metric('Aprobados', data.planesAprobados, AppTheme.primary),
            _Metric('Pendientes', data.planesPendientes,
                data.planesPendientes > 0 ? Colors.orangeAccent : AppTheme.textSecondary),
          ],
        ),
        const SizedBox(height: 12),
        _MetricSection(
          title:   'Alertas',
          icon:    Icons.notifications_active_rounded,
          columns: 2,
          metrics: [
            _Metric('Pendientes', data.alertasPendientes,
                data.alertasPendientes > 0 ? Colors.orangeAccent : AppTheme.primary),
            _Metric('Conflictos', data.conflictosMes,
                data.conflictosMes > 0 ? Colors.redAccent : AppTheme.primary,
                sub: 'este mes'),
          ],
        ),
        const SizedBox(height: 20),
        _AlertasCriticasSection(alertas: data.alertasCriticas),
        const SizedBox(height: 20),
        _ProgramasSection(programas: data.breakdownProgramas),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Metric section + tile
// ─────────────────────────────────────────────────────────────────────────────

class _Metric {
  final String  label;
  final int     value;
  final Color   color;
  final String? sub;
  const _Metric(this.label, this.value, this.color, {this.sub});
}

class _MetricSection extends StatelessWidget {
  final String        title;
  final IconData      icon;
  final List<_Metric> metrics;
  final int           columns;

  const _MetricSection({
    required this.title,
    required this.icon,
    required this.metrics,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <List<_Metric>>[];
    for (var i = 0; i < metrics.length; i += columns) {
      rows.add(metrics.sublist(
          i, (i + columns) > metrics.length ? metrics.length : i + columns));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AppTheme.primary, size: 16),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color:         AppTheme.textSecondary,
                fontSize:      11,
                fontWeight:    FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ]),
          const SizedBox(height: 14),
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) const SizedBox(height: 10),
            Row(
              children: [
                for (var c = 0; c < rows[r].length; c++) ...[
                  if (c > 0)
                    Container(
                      width: 1, height: 36,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: AppTheme.border,
                    ),
                  Expanded(child: _MetricTile(metric: rows[r][c])),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final _Metric metric;
  const _MetricTile({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${metric.value}',
          style: TextStyle(
            color:      metric.color,
            fontSize:   28,
            fontWeight: FontWeight.w800,
            height:     1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          metric.label,
          style: const TextStyle(
              color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
          maxLines:  1,
          overflow:  TextOverflow.ellipsis,
        ),
        if (metric.sub != null)
          Text(
            metric.sub!,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Alertas críticas
// ─────────────────────────────────────────────────────────────────────────────

class _AlertasCriticasSection extends StatelessWidget {
  final List<AlertaCriticaEntity> alertas;
  const _AlertasCriticasSection({required this.alertas});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          'Alertas Críticas de Conflicto',
          icon:      Icons.warning_amber_rounded,
          iconColor: Colors.redAccent,
        ),
        const SizedBox(height: 10),
        if (alertas.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:        AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border:       Border.all(color: AppTheme.border),
            ),
            child: const Row(children: [
              Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 18),
              SizedBox(width: 10),
              Text('Sin conflictos de horario activos',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            ]),
          )
        else
          ...alertas.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _AlertaCriticaTile(alerta: a),
          )),
      ],
    );
  }
}

class _AlertaCriticaTile extends StatelessWidget {
  final AlertaCriticaEntity alerta;
  const _AlertaCriticaTile({required this.alerta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: Colors.redAccent.withAlpha(100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alerta.descripcion,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _relativo(alerta.fechaCreacion),
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _relativo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours   < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays    < 7)  return 'Hace ${diff.inDays} día${diff.inDays > 1 ? 's' : ''}';
    return _fmtDate(dt);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Breakdown por programa
// ─────────────────────────────────────────────────────────────────────────────

class _ProgramasSection extends StatelessWidget {
  final List<SnapshotProgramaEntity> programas;
  const _ProgramasSection({required this.programas});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Por Programa', icon: Icons.stacked_bar_chart_rounded),
        const SizedBox(height: 10),
        if (programas.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:        AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border:       Border.all(color: AppTheme.border),
            ),
            child: const Text('Sin programas activos en este snapshot.',
                style: TextStyle(color: AppTheme.textSecondary)),
          )
        else
          ...programas.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ProgramaCard(programa: p),
          )),
      ],
    );
  }
}

class _ProgramaCard extends StatelessWidget {
  final SnapshotProgramaEntity programa;
  const _ProgramaCard({required this.programa});

  @override
  Widget build(BuildContext context) {
    final pct = (programa.avanceHorasPct / 100).clamp(0.0, 1.0);
    final barColor = pct >= 0.8
        ? AppTheme.primary
        : pct >= 0.4
            ? AppTheme.accent
            : Colors.orangeAccent;

    return Container(
      decoration: BoxDecoration(
        color:        AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppTheme.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: ExpansionTile(
        backgroundColor:          Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        shape:                    const Border(),
        collapsedShape:           const Border(),
        tilePadding:     const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor:          AppTheme.primary,
        collapsedIconColor: AppTheme.textSecondary,
        title: Text(
          programa.programaNombre,
          style: const TextStyle(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '${programa.fichasActivas} fichas · ${programa.estudiantesActivos} est.',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Horas ejecutadas',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              Text(
                '${programa.horasEjecutadas} / ${programa.horasPlanificadas} h',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value:           pct,
              backgroundColor: AppTheme.surfaceLight,
              valueColor:      AlwaysStoppedAnimation<Color>(barColor),
              minHeight:       8,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${programa.avanceHorasPct.toStringAsFixed(1)} %',
              style: TextStyle(
                  color: barColor, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 14),
          Row(children: [
            _MiniMetric('Lectiva',     programa.fichasLectiva,    AppTheme.accent),
            _MiniMetric('Productiva',  programa.fichasProductiva, AppTheme.textSecondary),
            _MiniMetric('Deserciones', programa.desercionesMes,
                programa.desercionesMes > 0 ? Colors.orangeAccent : AppTheme.textSecondary),
            _MiniMetric('Graduados',   programa.graduadosMes,     AppTheme.primary),
          ]),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final int    value;
  final Color  color;
  const _MiniMetric(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text('$value',
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 — Historial
// ─────────────────────────────────────────────────────────────────────────────

class _SnapshotListView extends StatefulWidget {
  const _SnapshotListView();

  @override
  State<_SnapshotListView> createState() => _SnapshotListViewState();
}

class _SnapshotListViewState extends State<_SnapshotListView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnaliticaProvider>().cargarSnapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = context.watch<AnaliticaProvider>();

    if (provider.snapshotsLoading) {
      return const CyberLoadingView();
    }
    if (provider.snapshotsError != null) {
      return CyberErrorView(
        message: provider.snapshotsError!,
        onRetry: () => context.read<AnaliticaProvider>().cargarSnapshots(),
      );
    }
    if (provider.snapshots.isEmpty) {
      return const CyberEmptyView(
        icon:     Icons.history_rounded,
        title:    'Sin historial',
        subtitle: 'No hay snapshots generados aún.',
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<AnaliticaProvider>().cargarSnapshots(),
      color: AppTheme.primary,
      child: ListView.separated(
        padding:          const EdgeInsets.all(16),
        itemCount:        provider.snapshots.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder:      (_, i)  => _SnapshotCard(snapshot: provider.snapshots[i]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de snapshot individual
// ─────────────────────────────────────────────────────────────────────────────

class _SnapshotCard extends StatelessWidget {
  final AnaliticaSnapshotEntity snapshot;
  const _SnapshotCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppTheme.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: ExpansionTile(
        backgroundColor:          Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        shape:                    const Border(),
        collapsedShape:           const Border(),
        tilePadding:     const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor:          AppTheme.primary,
        collapsedIconColor: AppTheme.textSecondary,
        title: Text(
          _fmtDate(snapshot.fecha),
          style: const TextStyle(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
        ),
        subtitle: Text(
          '${snapshot.fichasActivas} fichas · '
          '${snapshot.estudiantesActivos} est. · '
          '${snapshot.docentesActivos} doc.',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        children: [
          Wrap(
            spacing:    24,
            runSpacing: 12,
            children: [
              _HistMini('Lectiva',      snapshot.fichasLectiva,         AppTheme.accent),
              _HistMini('Productiva',   snapshot.fichasProductiva,      AppTheme.textSecondary),
              _HistMini('Deserciones',  snapshot.desercionesMes,
                  snapshot.desercionesMes    > 0 ? Colors.orangeAccent : AppTheme.textSecondary),
              _HistMini('Graduados',    snapshot.graduadosMes,          AppTheme.primary),
              _HistMini('Sobrecargados', snapshot.docentesSobrecargados,
                  snapshot.docentesSobrecargados > 0 ? Colors.orangeAccent : AppTheme.textSecondary),
              _HistMini('Alertas',      snapshot.alertasPendientes,
                  snapshot.alertasPendientes > 0 ? Colors.orangeAccent : AppTheme.primary),
              _HistMini('Conflictos',   snapshot.conflictosHorarioMes,
                  snapshot.conflictosHorarioMes  > 0 ? Colors.redAccent : AppTheme.primary),
              _HistMini('Planes OK',    snapshot.planesAprobados,       AppTheme.primary),
            ],
          ),
          if (snapshot.programas.isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(color: AppTheme.border, height: 1),
            const SizedBox(height: 12),
            Text(
              'PROGRAMAS (${snapshot.programas.length})',
              style: const TextStyle(
                color:         AppTheme.textSecondary,
                fontSize:      10,
                fontWeight:    FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            ...snapshot.programas.map((p) => _ProgramaRow(programa: p)),
          ],
        ],
      ),
    );
  }
}

class _ProgramaRow extends StatelessWidget {
  final SnapshotProgramaEntity programa;
  const _ProgramaRow({required this.programa});

  @override
  Widget build(BuildContext context) {
    final pct = (programa.avanceHorasPct / 100).clamp(0.0, 1.0);
    final barColor = pct >= 0.8
        ? AppTheme.primary
        : pct >= 0.4
            ? AppTheme.accent
            : Colors.orangeAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  programa.programaNombre,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${programa.horasEjecutadas}h / ${programa.horasPlanificadas}h',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
              const SizedBox(width: 6),
              Text(
                '${programa.avanceHorasPct.toStringAsFixed(0)}%',
                style: TextStyle(
                    color: barColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value:           pct,
              backgroundColor: AppTheme.surfaceLight,
              valueColor:      AlwaysStoppedAnimation<Color>(barColor),
              minHeight:       5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistMini extends StatelessWidget {
  final String label;
  final int    value;
  final Color  color;
  const _HistMini(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value',
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String   title;
  final IconData icon;
  final Color?   iconColor;
  const _SectionHeader(this.title, {required this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: iconColor ?? AppTheme.primary, size: 16),
      const SizedBox(width: 8),
      Text(
        title.toUpperCase(),
        style: const TextStyle(
          color:         AppTheme.textSecondary,
          fontSize:      11,
          fontWeight:    FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    ]);
  }
}

String _fmtDate(DateTime d) {
  const m = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}
