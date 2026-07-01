// lib/features/programa/presentation/widgets/views/programa_detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/date_format.dart';
import '../../../../../core/role_helper.dart';
import '../../../domain/entities/version_programa_entity.dart';
import '../../providers/programa_provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/common/state_views.dart';
import '../../../../../core/widgets/common/status_chip.dart';
import 'programa_form_view.dart';
import 'version_detail_view.dart';
import 'version_form_view.dart';

class ProgramaDetailView extends StatefulWidget {
  final int programaId;

  const ProgramaDetailView({super.key, required this.programaId});

  @override
  State<ProgramaDetailView> createState() => _ProgramaDetailViewState();
}

class _ProgramaDetailViewState extends State<ProgramaDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgramaProvider>().fetchDetail(widget.programaId);
    });
  }

  Future<void> _refresh() {
    return context.read<ProgramaProvider>().fetchDetail(widget.programaId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgramaProvider>();
    final canManage = isManagerRole(context);
    final programa = provider.selected;
    final isCurrent = programa != null && programa.id == widget.programaId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del programa'),
        actions: [
          if (canManage && isCurrent)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProgramaFormView(programaId: widget.programaId),
                  ),
                );
                if (updated != null) _refresh();
              },
            ),
        ],
      ),
      floatingActionButton: canManage && isCurrent
          ? FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VersionFormView(
                      programaId: programa.id,
                      programaNombre: programa.nombre,
                    ),
                  ),
                );
                if (created != null) _refresh();
              },
              icon: const Icon(Icons.add),
              label: const Text('Nueva versión'),
            )
          : null,
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          programa.nombre,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      StatusChip.estado(programa.estado.value, programa.estadoDisplay),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _InfoBlock(label: 'Nivel', value: programa.nivelDisplay),
                      _InfoBlock(
                        label: 'Tipo de formación',
                        value: programa.tipoFormacionDisplay,
                      ),
                      _InfoBlock(
                        label: 'Horas lectivas',
                        value: '${programa.horasLectivas} h',
                      ),
                      _InfoBlock(
                        label: 'Horas prácticas',
                        value: '${programa.horasPracticas} h',
                      ),
                      _InfoBlock(label: 'Total de horas', value: '${programa.totalHoras} h'),
                      _InfoBlock(
                        label: 'Trimestres totales',
                        value: '${programa.trimestresTotales}',
                      ),
                      if (programa.esCadenaFormacion)
                        _InfoBlock(
                          label: 'Trimestres en etapa lectiva',
                          value: '${programa.trimestresCadena ?? '-'}',
                        ),
                    ],
                  ),
                  if (programa.descripcion.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Descripción', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      programa.descripcion,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Text('Versiones', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(width: 8),
                      Text(
                        '(${programa.versiones.length})',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (programa.versiones.isEmpty)
                    const EmptyStateView(
                      message: 'Este programa todavía no tiene versiones.',
                      icon: Icons.dns_outlined,
                    )
                  else
                    ...programa.versiones.map((v) => _VersionTile(version: v)),
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

class _VersionTile extends StatelessWidget {
  final VersionResumenEntity version;

  const _VersionTile({required this.version});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VersionDetailView(versionId: version.id)),
          );
        },
        title: Row(
          children: [
            Text('Versión ${version.numero}'),
            if (version.vigente) ...[
              const SizedBox(width: 8),
              const StatusChip(label: 'Vigente', color: AppTheme.primary),
            ],
          ],
        ),
        subtitle: Text(
          '${formatDate(version.fechaInicio)} — '
          '${version.fechaFin != null ? formatDate(version.fechaFin) : 'sin fin'}'
          '  ·  ${version.totalModulos} módulo(s)  ·  ${version.totalHoras} h',
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      ),
    );
  }
}
