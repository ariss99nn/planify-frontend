// lib/features/programa/presentation/widgets/views/modulo_detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/date_format.dart';
import '../../../../docentes/data/models/habilitacion_model.dart';
import '../../../../docentes/domain/entities/habilitacion_entity.dart';
import '../../../../../core/role_helper.dart';
import '../../providers/modulo_provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/common/state_views.dart';
import '../../../../../core/widgets/common/status_chip.dart';
import 'modulo_form_view.dart';

class ModuloDetailView extends StatefulWidget {
  final int moduloId;

  const ModuloDetailView({super.key, required this.moduloId});

  @override
  State<ModuloDetailView> createState() => _ModuloDetailViewState();
}

class _ModuloDetailViewState extends State<ModuloDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ModuloProvider>().fetchDetail(widget.moduloId);
    });
  }

  Future<void> _refresh() {
    return context.read<ModuloProvider>().fetchDetail(widget.moduloId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ModuloProvider>();
    final canManage = isManagerRole(context);
    final modulo = provider.selected;
    final isCurrent = modulo != null && modulo.id == widget.moduloId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del módulo'),
        actions: [
          if (canManage && isCurrent)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ModuloFormView(
                      versionId: modulo.version.id,
                      versionNumero: modulo.version.numero,
                      moduloId: widget.moduloId,
                    ),
                  ),
                );
                if (updated != null) _refresh();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (provider.isLoadingDetail && !isCurrent) return const LoadingView();
            if (provider.detailError != null && !isCurrent) {
              return ErrorRetryView(message: provider.detailError!, onRetry: _refresh);
            }
            if (!isCurrent) return const LoadingView();

            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Versión ${modulo.version.numero} · ${modulo.version.programaNombre}',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          modulo.nombre,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      StatusChip.estado(modulo.estado.value, modulo.estadoDisplay),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _InfoBlock(label: 'Orden', value: '${modulo.orden}'),
                      _InfoBlock(label: 'Horas lectivas', value: '${modulo.horasLectivas} h'),
                      _InfoBlock(label: 'Horas prácticas', value: '${modulo.horasPracticas} h'),
                      _InfoBlock(label: 'Total de horas', value: '${modulo.totalHoras} h'),
                    ],
                  ),
                  if (modulo.descripcion.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Descripción', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      modulo.descripcion,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Text('Docentes habilitados', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (modulo.docentesAsignados.isEmpty)
                    const EmptyStateView(
                      message: 'Ningún docente habilitado para este módulo.',
                      icon: Icons.person_off_outlined,
                    )
                  else
                    Card(
                      child: Column(
                        children:
                            modulo.docentesAsignados.map((h) => _DocenteTile(habilitacion: h)).toList(),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DocenteTile extends StatelessWidget {
  final HabilitacionModel habilitacion;

  const _DocenteTile({required this.habilitacion});

  @override
  Widget build(BuildContext context) {
    final detalle = habilitacion.nivel == HabilitacionNivel.asignatura
        ? habilitacion.asignaturaNombre
        : habilitacion.nivelDisplay;

    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: AppTheme.surfaceLight,
        child: Icon(Icons.person_outline, color: AppTheme.primary),
      ),
      title: Text(habilitacion.docenteNombre),
      subtitle: Text(
        [
          if (detalle != null && detalle.isNotEmpty) detalle,
          'Desde ${formatDate(habilitacion.fechaDesde)}'
              '${habilitacion.fechaHasta != null ? ' hasta ${formatDate(habilitacion.fechaHasta)}' : ''}',
        ].join('  ·  '),
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
    );
  }
}
