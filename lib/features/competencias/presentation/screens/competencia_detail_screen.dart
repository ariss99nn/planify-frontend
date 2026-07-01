import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/competencia_provider.dart';
import '../../competencia_theme.dart';
import '../../../../core/widgets/widgets.dart';
import 'competencia_form_screen.dart';
import 'competencia_transversal_form_screen.dart';
import 'rap_list_screen.dart';

const _managers = {'COORDINADOR', 'ADMINISTRATIVO'};

class CompetenciaDetailScreen extends StatefulWidget {
  final int    id;
  final String userRole;

  const CompetenciaDetailScreen(
      {super.key, required this.id, required this.userRole});

  @override
  State<CompetenciaDetailScreen> createState() =>
      _CompetenciaDetailScreenState();
}

class _CompetenciaDetailScreenState extends State<CompetenciaDetailScreen> {
  bool get _isManager => _managers.contains(widget.userRole);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompetenciaProvider>().loadDetail(widget.id);
    });
  }

  Future<void> _delete(BuildContext context) async {
    final prov = context.read<CompetenciaProvider>();
    final item = prov.detail!;
    final confirmed = await CyberDialog.confirm(
      context: context,
      title: 'Eliminar competencia',
      message: item.esInduccion
          ? '"${item.codigo}" está marcada como inducción. Quita esa marca antes de eliminarla.'
          : '¿Eliminar "${item.codigo} — ${item.nombre}"? Solo es posible si no tiene resultados de aprendizaje asociados.',
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
          content: Text('Competencia eliminada.'),
          backgroundColor: CT.primary,
        ),
      );
    }
  }

  void _openEdit(BuildContext context) {
    final prov = context.read<CompetenciaProvider>();
    final item = prov.detail!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: prov,
          child: item.isTransversal
              ? CompetenciaTransversalFormScreen(existing: item)
              : CompetenciaFormScreen(existing: item),
        ),
      ),
    ).then((_) {
      if (mounted) prov.loadDetail(widget.id);
    });
  }

  void _openResultados(
      BuildContext context, int competenciaId, String competenciaNombre) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RapListScreen(
          userRole: widget.userRole,
          competenciaId: competenciaId,
          competenciaNombre: competenciaNombre,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CT.background,
      body: Consumer<CompetenciaProvider>(
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
                    item.codigo,
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
                      Text(
                        item.nombre,
                        style: const TextStyle(
                          color: CT.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          _Chip(
                            label: item.tipoDisplay,
                            color: item.isTransversal
                                ? CT.transversal
                                : CT.principal,
                          ),
                          if (item.esInduccion)
                            const _Chip(label: 'Inducción', color: CT.accent),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _DetailCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.isPrincipal)
                              _LabelValue(
                                  label: 'Asignatura',
                                  value: item.asignaturaNombre ?? '—'),
                            if (item.isTransversal) ...[
                              _LabelValue(
                                label: 'Horas / trimestre',
                                value: item.horasTrimestre != null
                                    ? '${item.horasTrimestre} h'
                                    : '—',
                              ),
                              _LabelValue(
                                label: 'Inducción activa',
                                value: item.inductionActiva ? 'Sí' : 'No',
                                valueColor: item.inductionActiva
                                    ? CT.primary
                                    : CT.textSec,
                              ),
                            ],
                            if (item.descripcion.isNotEmpty) ...[
                              const Divider(color: CT.border, height: 24),
                              _LabelValue(
                                  label: 'Descripción',
                                  value: item.descripcion),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'RESULTADOS DE APRENDIZAJE',
                                  style: TextStyle(
                                    color: CT.textSec,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${item.resultados.length} registrados',
                                  style: const TextStyle(
                                      color: CT.textSec, fontSize: 11),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.open_in_new,
                                      color: CT.primary, size: 18),
                                  onPressed: () => _openResultados(
                                      context, item.id, item.nombre),
                                  tooltip: 'Ver todos',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (item.resultados.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'Sin resultados registrados aún.',
                                  style: TextStyle(
                                      color: CT.textSec, fontSize: 12),
                                ),
                              )
                            else
                              ...item.resultados.take(5).map(
                                    (r) => _CompactItem(
                                      code: r['codigo'] as String? ?? '',
                                      name: r['descripcion'] as String? ?? '',
                                      color: CT.accent,
                                    ),
                                  ),
                          ],
                        ),
                      ),
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

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _LabelValue(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(color: CT.textSec, fontSize: 12)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? CT.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Text(
              name,
              style: const TextStyle(color: CT.textPrimary, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
