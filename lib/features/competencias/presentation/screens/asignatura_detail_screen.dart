import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/asignatura_provider.dart';
import '../../competencia_theme.dart';
import '../../../../core/widgets/widgets.dart';
import 'asignatura_form_screen.dart';

const _managers = {'COORDINADOR', 'ADMINISTRATIVO'};

class AsignaturaDetailScreen extends StatefulWidget {
  final int    id;
  final String userRole;

  const AsignaturaDetailScreen(
      {super.key, required this.id, required this.userRole});

  @override
  State<AsignaturaDetailScreen> createState() => _AsignaturaDetailScreenState();
}

class _AsignaturaDetailScreenState extends State<AsignaturaDetailScreen> {
  bool get _isManager => _managers.contains(widget.userRole);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AsignaturaProvider>().loadDetail(widget.id);
    });
  }

  Future<void> _delete(BuildContext context) async {
    final prov = context.read<AsignaturaProvider>();
    final item = prov.detail!;
    final confirmed = await CyberDialog.confirm(
      context: context,
      title: 'Eliminar asignatura',
      message:
          '¿Eliminar "${item.nombre}"? Esta acción es irreversible y solo es posible si no tiene competencias asociadas.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    final error = await prov.delete(item.id);
    if (!mounted) return;
    if (error != null) {
      await CyberDialog.error(
        context: context,
        title: 'No se pudo eliminar',
        message: error,
        icon: Icons.warning_amber_rounded,
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asignatura eliminada.'),
          backgroundColor: CT.primary,
        ),
      );
    }
  }

  void _openEdit(BuildContext context) {
    final prov = context.read<AsignaturaProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: prov,
          child: AsignaturaFormScreen(existing: prov.detail),
        ),
      ),
    ).then((_) {
      if (mounted) prov.loadDetail(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CT.background,
      body: Consumer<AsignaturaProvider>(
        builder: (context, prov, _) {
          if (prov.isLoadingDetail) {
            return const Center(
                child: CircularProgressIndicator(color: CT.primary));
          }
          if (prov.detailError != null) {
            return CyberErrorView(
              message: prov.detailError!,
              onRetry: () => prov.loadDetail(widget.id),
            );
          }
          final item = prov.detail;
          if (item == null) return const SizedBox.shrink();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: CT.background,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    item.nombre,
                    style: const TextStyle(
                      color: CT.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
                ),
                actions: _isManager
                    ? [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: CT.primary),
                          onPressed: () => _openEdit(context),
                          tooltip: 'Editar',
                        ),
                        IconButton(
                          icon: prov.isDeleting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: CT.error,
                                  ))
                              : const Icon(Icons.delete_outline,
                                  color: CT.error),
                          onPressed: prov.isDeleting
                              ? null
                              : () => _delete(context),
                          tooltip: 'Eliminar',
                        ),
                        const SizedBox(width: 8),
                      ]
                    : null,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: [
                          _Chip(label: item.tipoDisplay, color: CT.primary),
                          _Chip(
                            label: item.estado,
                            color: item.estado == 'ACTIVA'
                                ? CT.primary
                                : CT.textSec,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _DetailCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle('INFORMACIÓN GENERAL'),
                            const SizedBox(height: 8),
                            _LabelValue(label: 'Tipo', value: item.tipoDisplay),
                            _LabelValue(
                                label: 'Estado', value: item.estadoDisplay),
                            if (item.descripcion.isNotEmpty)
                              _LabelValue(
                                  label: 'Descripción',
                                  value: item.descripcion),
                          ],
                        ),
                      ),
                      if (item.competencias.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _DetailCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionTitle(
                                'COMPETENCIAS ASOCIADAS  •  ${item.competencias.length}',
                              ),
                              const SizedBox(height: 8),
                              ...item.competencias.map(
                                (c) => _CompactItem(
                                  code: c['codigo'] as String? ?? '',
                                  name: c['nombre'] as String? ?? '',
                                  color: CT.principal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (item.docentesAsignados.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _DetailCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionTitle(
                                'DOCENTES ASIGNADOS  •  ${item.docentesAsignados.length}',
                              ),
                              const SizedBox(height: 8),
                              ...item.docentesAsignados.map(
                                (d) => _CompactItem(
                                  code: '',
                                  name: (d['docente']
                                              as Map<String, dynamic>?)?[
                                          'nombre'] as String? ??
                                      'Docente',
                                  color: CT.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (item.createdAt != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.schedule,
                                size: 12, color: CT.textSec),
                            const SizedBox(width: 4),
                            Text(
                              'Creada: ${_fmt(item.createdAt!)}  •  Actualizada: ${_fmt(item.updatedAt!)}',
                              style: const TextStyle(
                                  color: CT.textSec, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

// ── Widgets locales ───────────────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final Widget child;
  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CT.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CT.border),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: CT.textSec,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  const _LabelValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(color: CT.textSec, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: CT.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color  color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _CompactItem extends StatelessWidget {
  final String code;
  final String name;
  final Color  color;
  const _CompactItem(
      {required this.code, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          if (code.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(code,
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(name,
                style: const TextStyle(color: CT.textPrimary, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
