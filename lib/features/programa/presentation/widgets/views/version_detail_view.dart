// lib/features/programa/presentation/widgets/views/version_detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/date_format.dart';
import '../../../../../core/role_helper.dart';
import '../../../domain/entities/modulo_entity.dart';
import '../../providers/version_provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/common/state_views.dart';
import '../../../../../core/widgets/common/status_chip.dart';
import 'version_form_view.dart';
import 'modulo_detail_view.dart';
import 'modulo_form_view.dart';

class VersionDetailView extends StatefulWidget {
  final int versionId;

  const VersionDetailView({super.key, required this.versionId});

  @override
  State<VersionDetailView> createState() => _VersionDetailViewState();
}

class _VersionDetailViewState extends State<VersionDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VersionProvider>().fetchDetail(widget.versionId);
    });
  }

  Future<void> _refresh() {
    return context.read<VersionProvider>().fetchDetail(widget.versionId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VersionProvider>();
    final canManage = isManagerRole(context);
    final version = provider.selected;
    final isCurrent = version != null && version.id == widget.versionId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de versión'),
        actions: [
          if (canManage && isCurrent)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VersionFormView(
                      programaId: version.programa.id,
                      programaNombre: version.programa.nombre,
                      versionId: widget.versionId,
                    ),
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
                    builder: (_) => ModuloFormView(
                      versionId: version.id,
                      versionNumero: version.numero,
                    ),
                  ),
                );
                if (created != null) _refresh();
              },
              icon: const Icon(Icons.add),
              label: const Text('Nuevo módulo'),
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
                          '${version.programa.nombre} · v${version.numero}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      if (version.vigente)
                        const StatusChip(label: 'Vigente', color: AppTheme.primary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _InfoBlock(
                        label: 'Fecha de inicio',
                        value: formatDate(version.fechaInicio),
                      ),
                      _InfoBlock(
                        label: 'Fecha de fin',
                        value: version.fechaFin != null
                            ? formatDate(version.fechaFin)
                            : 'Sin definir',
                      ),
                      _InfoBlock(
                        label: 'Total de horas',
                        value: '${version.totalHoras} h',
                        helper: 'Solo módulos activos',
                      ),
                    ],
                  ),
                  if (version.descripcion.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Descripción', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      version.descripcion,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Text('Módulos', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(width: 8),
                      Text(
                        '(${version.modulos.length})',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (version.modulos.isEmpty)
                    const EmptyStateView(
                      message: 'Esta versión todavía no tiene módulos.',
                      icon: Icons.view_module_outlined,
                    )
                  else
                    ...version.modulos.map((m) => _ModuloTile(modulo: m)),
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
  final String? helper;

  const _InfoBlock({required this.label, required this.value, this.helper});

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
          if (helper != null)
            Text(helper!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ModuloTile extends StatelessWidget {
  final ModuloResumenEntity modulo;

  const _ModuloTile({required this.modulo});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ModuloDetailView(moduloId: modulo.id)),
          );
        },
        leading: CircleAvatar(
          backgroundColor: AppTheme.surfaceLight,
          child: Text(
            '${modulo.orden}',
            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(modulo.nombre),
        subtitle: Text('${modulo.totalHoras} h  ·  ${modulo.totalAsignaturas} asignatura(s)'),
        trailing: StatusChip.estado(modulo.estado.value, modulo.estadoDisplay),
      ),
    );
  }
}
